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
7. **Push image** *(skipped on pull_request)* — `skopeo copy` from the
   rechunked OCI layout, capturing the digest so the exact pushed ref can
   be signed.
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
    IMG="${{ steps.meta.outputs.image }}"
    CHUNKAH_CONFIG_STR=$(podman inspect "$IMG" | jq '.[0].Config')
    export CHUNKAH_CONFIG_STR
    mkdir -p /tmp/chunked
    podman run --rm \
      --mount=type=image,src="$IMG",dst=/chunkah \
      -v /tmp/chunked:/out:z \
      -e CHUNKAH_CONFIG_STR quay.io/coreos/chunkah:v0.6.0 build \
        --max-layers 120 --compressed --output oci:/out/image
```

The push step then copies straight out of that OCI layout:

```yaml
skopeo copy --authfile="$HOME/.docker/config.json" \
  --digestfile=/tmp/digest \
  oci:/tmp/chunked/image \
  docker://${{ steps.meta.outputs.image }}
```

Key points:

- **`CHUNKAH_CONFIG_STR`** carries the original image's OCI config
  (labels, entrypoint, env) back into the rechunked image. Without it,
  chunkah emits an image with an empty config and the `SHELL`/`LANG`/
  `PATH`/`CMD` set up in the `Containerfile` would be lost.
- **The rechunked image never enters containers-storage.** `--output oci:`
  writes the OCI directory layout straight to disk, and the push reads
  from that directory. This is why the push uses `skopeo copy` rather than
  `podman push` — **a `podman push` here would publish the *pre-chunk*
  image**, because the local tag still points at the original build.
- **`--compressed` is deliberate.** chunkah leaves layers uncompressed by
  default, on the assumption the output is about to be imported into a
  container storage backend that would just decompress them again. Here
  the output goes to a registry instead, which wants gzip blobs — so
  compressing once in chunkah lets skopeo pass the blobs through
  untouched rather than compressing them itself during the push.
- The OCI layout carries **no ref name** (its `index.json` has null
  annotations), which is fine: it holds exactly one manifest, so
  `oci:/tmp/chunked/image` resolves without a tag suffix.
- The digest is captured with `--digestfile` so cosign signs the exact
  ref that was pushed.
- **`--max-layers 120`.** chunkah's default is 64. The hard ceiling is
  Docker's: its layer store rejects any image deeper than **125** layers
  (`maxLayerDepth` in moby), with `max depth exceeded`. Podman's
  containers-storage allows 500, and ghcr.io enforces no cap. 120 sits
  just under Docker's limit for finer layers, leaving 5 layers so a Docker
  user can still `FROM` this image and add a few instructions. Don't go
  above 125, or the image stops working under Docker. (Sivablue uses 128
  safely because it's a bootc image that Docker never runs.)
- The chunkah image tag is pinned to `v0.6.0` and bumped deliberately,
  not auto-tracked, since it's young/fast-moving tooling.

### Why not pipe into `podman load`

The original implementation piped chunkah's archive straight into
`podman load`. It worked, but on an image this size it was pathologically
slow — roughly **2.3x the build time** and still climbing when it was
abandoned (24m build vs 56m+ rechunk).

The cause is that the pipe forces the whole image through disk three
times over: the original sits in containers-storage, `podman load` spools
the uncompressed archive into `/var/tmp`, and then imports a third copy
back into containers-storage. For a ~16 GB image that approaches the
runner's free disk, so it is a correctness risk as well as a slow one.

chunkah's own README calls this out, recommending `--output oci:PATH` plus
`skopeo copy` to get the same result without the tar/untar round trip.

### Runner podman version constraints — read before editing this step

The GitHub `ubuntu-latest` runner ships **podman 4.9.3**, which is
materially older than what you likely have locally. Two things follow, and
both have already bitten this step once:

1. **Use `dst=`, not `dest=`, in the `--mount` flag.** Podman 4.9.3's
   mount parser accepts only `target`, `dst`, and `destination` as the
   destination key — `dest` is a newer alias added in podman 5.x. Using
   `dest=` works fine locally on podman 5.x and then fails in CI with
   `Error: dest: invalid mount option`.
2. **Don't reintroduce a pipe without `set -o pipefail`.** GitHub Actions
   runs `run:` blocks with `bash -e`, but *not* `pipefail`. The original
   implementation piped chunkah into `podman load`, and a chunkah failure
   was therefore masked: `podman load` received garbage and the visible
   error became a misleading `payload does not match any of the supported
   image formats`, burying the real cause. The current step has no pipe,
   so failures surface directly — keep it that way, or re-add `pipefail`.

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

It runs the same chunkah invocation as CI (`--max-layers 120 --compressed --output oci:`
into a temporary directory), then differs only in the last step: where CI
pushes that OCI layout to the registry with `skopeo copy`, `just chunk`
copies it into local `containers-storage` under a separate
`:<tag>-chunked` tag, so the image is inspectable side by side with the
original. The temp directory is removed on exit.

It requires `skopeo` locally in addition to `podman`, `just` and `jq`. The
chunkah version is controlled by the `chunkah_version` variable in the
`Justfile` (override with the `CHUNKAH_VERSION` env var).

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
