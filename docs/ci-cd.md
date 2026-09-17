# CI/CD

Two GitHub Actions workflows live in `.github/workflows/`.

## `build-image.yml` — build, rechunk, push, sign

### Triggers

- `push` to `master` (ignoring `**/README.md`)
- `pull_request` to `master` (builds only — does **not** push or sign)
- `schedule`: weekly, `cron: '0 0 * * 0'` (Sunday 00:00 UTC)

### Permissions

The job requests `contents: read`, `packages: write`, and
`id-token: write`. The last is required for keyless cosign signing (see
[Signing](#signing)).

### Steps, in order

1. **Checkout** the repo.
2. **Log into ghcr.io** with the built-in `GITHUB_TOKEN`.
3. **Install cosign.**
4. **Set image reference** — lowercases the owner and composes
   `ghcr.io/<owner>/kali-cloud:latest` into a step output.
5. **Build image** — `podman build`.
6. **Rechunk image** — see [Rechunking](#rechunking) below.
7. **Push image** *(skipped on pull_request)* — `podman push`, capturing
   the digest so the exact pushed ref can be signed.
8. **Sign image** *(skipped on pull_request)* — keyless cosign.

## Rechunking

### Why

The image is large and rebuilt weekly. Without rechunking, the layers are
a handful of monolithic blobs, so a change to any one tool invalidates a
huge layer and forces users to re-pull most of the image.

**chunkah** ([quay.io/coreos/chunkah](https://github.com/coreos/chunkah))
splits the final rootfs into many smaller, content-grouped layers. Because
OCI layers are content-addressed, a layer whose files are byte-identical
to last week's build keeps the same digest and is skipped on pull
automatically — no diffing logic required. Smaller, more granular layers
also mean a single changed tool no longer invalidates everything sharing
its layer.

chunkah is **content-agnostic** — it does not require an OSTree/bootc
image, which is why it fits this plain apt-based image. (The ublue-style
`hhd-dev/rechunk` CI action, by contrast, requires an OSTree image and
does **not** apply here.)

### How the CI step works

```yaml
- name: Rechunk image
  run: |
    set -o pipefail
    IMG="${{ steps.meta.outputs.image }}"
    CHUNKAH_CONFIG_STR=$(podman inspect "$IMG" | jq '.[0].Config')
    export CHUNKAH_CONFIG_STR
    podman run --rm --mount=type=image,src="$IMG",dst=/chunkah \
      -e CHUNKAH_CONFIG_STR quay.io/coreos/chunkah:v0.6.0 build \
        -t "$IMG" | podman load
```

Key points:

- **`CHUNKAH_CONFIG_STR`** carries the original image's OCI config
  (labels, entrypoint, env) back into the rechunked image. Without it,
  chunkah emits an image with an empty config and the `SHELL`/`LANG`/
  `PATH`/`CMD` set up in the `Containerfile` would be lost.
- The output is re-tagged with the **same** `$IMG` tag and piped through
  `podman load`, which **overwrites the tag in place** — the tag now
  points at the rechunked image. The subsequent push therefore pushes the
  rechunked version, not the pre-chunk one.
- chunkah defaults to a **max of 64 layers** (configurable with
  `--max-layers`). 64 is a safe default: it stays well under the ~125-127
  layer ceiling that the `overlay2` storage driver imposes on hosts
  pulling/running the image. Note ghcr.io itself does not enforce a
  layer-count cap; the ceiling is a container-runtime constraint, so
  raising `--max-layers` toward 128 buys nothing and eats the safety
  margin.
- The chunkah image tag is pinned to `v0.6.0` and bumped deliberately,
  not auto-tracked, since it's young/fast-moving tooling.

### Runner podman version constraints — read before editing this step

The GitHub `ubuntu-latest` runner ships **podman 4.9.3**, which is
materially older than what you likely have locally. Two things follow, and
both have already bitten this step once:

1. **Use `dst=`, not `dest=`, in the `--mount` flag.** Podman 4.9.3's
   mount parser accepts only `target`, `dst`, and `destination` as the
   destination key — `dest` is a newer alias added in podman 5.x. Using
   `dest=` works fine locally on podman 5.x and then fails in CI with
   `Error: dest: invalid mount option`.
2. **Keep `set -o pipefail` at the top of the step.** GitHub Actions runs
   `run:` blocks with `bash -e`, but *not* `pipefail`. Because chunkah's
   output is piped into `podman load`, a chunkah failure without
   `pipefail` is masked: `podman load` receives garbage and the visible
   error becomes a misleading `payload does not match any of the supported
   image formats`, burying the real cause.

If you change this step, remember the local/CI podman version gap —
verify option names against the runner's version rather than assuming your
local podman's behaviour, e.g. against
`containers/podman` at tag `v4.9.3`.

### Reproducing it locally: `just chunk`

`just chunk` reproduces the rechunk step against an already-built local
image so you can inspect the before/after:

```bash
just build   # produces kali-cloud:latest
just chunk   # produces kali-cloud:latest-chunked and prints layer counts
```

Unlike CI (which overwrites the tag in place, because it's about to push
that exact tag), `just chunk` writes to a separate `:<tag>-chunked` tag so
your original build is left untouched for comparison. The chunkah version
is controlled by the `chunkah_version` variable in the `Justfile`
(override with the `CHUNKAH_VERSION` env var).

## Signing

Signing is **keyless cosign** via GitHub Actions OIDC (`id-token: write`).
There is no managed key and no committed public key — identity is proven
by the workflow's OIDC token. (`.gitignore` still excludes `cosign.key`
as a guard against anyone accidentally committing a local key.)

## `clean.yml` — image retention

A separate scheduled workflow prunes old published images from ghcr.io:

- **Triggers:** weekly (`cron: '0 0 * * 0'`) and manual
  (`workflow_dispatch`).
- Uses `dataaxiom/ghcr-cleanup-action` (pinned by commit SHA) to delete
  images older than 30 days from the `kali-cloud` package, keeping the last
  7 tagged and 7 untagged, and removing orphaned images.
