# Build architecture

## What this repo produces

This repo builds a **Kali Linux container image** — it is not application
code. The image packs offensive-security tooling for on-network and Active
Directory work **plus cloud-pentest / cloud-audit tooling**. It is rebuilt
weekly by CI and published to `ghcr.io/sir-mudkip/kali-cloud`.

The container boots into a plain shell (`CMD ["/bin/bash"]`); there is no
init system, so systemd-managed services do not run inside it. It is meant
to be run with `--privileged --network host` for raw network access and
shell catching.

This is the **cloud fork** of the base `kali` repo. It ships
AWS/Azure/Kubernetes/OCI and multi-cloud tooling (kubectl/krew, prowler,
pacu, cloudfox, kics, snotra_*, etc.). **gcloud / GCP tooling is
intentionally excluded — do not add it.**

There is no test suite. "Does it build" is the test: a change is correct
when `just build` completes **and** the tool you added is actually present
and runnable in the resulting image. Building is expensive (tens of
minutes, very large result), so reason carefully about a change before
building rather than using the build as a guess-and-check loop.

### Base image

Both stages start from `docker.io/kalilinux/kali-rolling`.

Kali is a **rolling release**. The same `Containerfile` built a week apart
can produce different package versions, and packages can disappear from
the repos between builds. A build failure in `10-tools.sh` that names a
package is usually upstream churn, not a regression in this repo — verify
the package still exists in Kali before assuming the code is wrong.

Both stages deliberately use the **same** base. Binaries compiled in the
builder stage are copied into the final stage and must link against
identical runtime libraries; changing one base without the other produces
binaries that fail at runtime with missing or mismatched shared objects.

## Toolchain

The build uses **`just`** (see the repo-root `Justfile`) as a task runner
and **`podman`** as the image builder — not docker, for the build itself.
The published image is OCI-compliant and runs fine under either runtime.

Local commands:

| Command        | What it does                                                                                             |
| -------------- | -------------------------------------------------------------------------------------------------------- |
| `just build`   | Build the image locally with `podman build`, tagging `kali-cloud:latest`. Adds the `SHA_HEAD_SHORT` build-arg only when the git tree is clean. |
| `just chunk`   | Rechunk an already-built image locally to reproduce the CI rechunk step (see [ci-cd.md](ci-cd.md)).      |
| `just lint`    | Run `shellcheck` on every `*.sh` file in the repo.                                                        |
| `just format`  | Run `shfmt --write` on every `*.sh` file in the repo.                                                     |

## The two-stage Containerfile

`Containerfile` is a **two-stage build**. The purpose of the split is to
keep the compiler toolchain (golang, build-essential, etc.) out of the
shipped image.

### Stage 1 — `builder`

```dockerfile
FROM docker.io/kalilinux/kali-rolling AS builder
```

Runs **`build/00-go-installs.sh`**, which installs the golang toolchain
and build dependencies, then compiles the Go tools (`nuclei`, plus the
cloud Go tools `cloudfox`, `aws-enumerator`, `GoAWSConsoleSpray`, and the
web fuzzer `ffuf`) and the `kics` IaC scanner. Each build passes
`-ldflags="-s -w"` to strip the symbol table and DWARF debug info, cutting
the shipped binaries by roughly 25-30%. (kics is the exception: its
Makefile bakes a version string into its own ldflags, so it is built
normally and then `strip`ped afterward.)

Each resulting binary is `install`ed into `/usr/local/bin` *inside the
builder stage*. Nothing from this stage ships directly — the final stage
cherry-picks the binaries with `COPY --from=builder`.

Note the builder copies in **only** `build/00-go-installs.sh`, not the
whole `build/` directory:

```dockerfile
COPY build/00-go-installs.sh /build/00-go-installs.sh
```

That script therefore **cannot** `source /build/helper_functions` or call
`/build/ghcurl` — neither exists in this stage. It doesn't need to: Go
tools are tracked with `@latest` through the Go module proxy, so they
don't need the GitHub release lookup the final-stage scripts use.

The builder uses the **same** `kali-rolling` base as the final stage, so
the compiled binaries link against identical runtime libraries.

### Stage 2 — final image

```dockerfile
FROM docker.io/kalilinux/kali-rolling
```

This stage assembles the shipped image in the following order:

1. Sets environment (`SHELL`, `LANG`, `PIP_NO_CACHE_DIR=1`, and
   `PATH=/root/.local/bin:$PATH` so pipx-installed apps are on PATH at
   both build and run time).
2. Copies `config/` into `/root` (see [config vendoring](#config-vendoring)).
3. Copies the whole `build/` directory to `/build`.
4. Runs the build scripts **in order** (see below), each as its own `RUN`
   layer with `cache`/`tmpfs` mounts.
5. `COPY --from=builder` pulls the compiled binaries (and `/opt/kics`) out
   of the builder stage.
6. Pre-fetches nuclei templates (`nuclei -ut`).
7. Runs a final `apt update && apt upgrade` layer.
8. Sets `WORKDIR /root` and `CMD ["/bin/bash"]`.

#### The mount flags on each `RUN`

Every build-script `RUN` uses:

```dockerfile
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /build/NN-script.sh
```

- The two `cache` mounts persist apt's package cache and logs across
  builds so repeated builds don't re-download everything.
- The `tmpfs` mount on `/tmp` keeps large transient extraction artifacts
  out of the image layer entirely.

Because each script is a **single `RUN` layer**, any file a script creates
and does not delete is baked permanently into that layer — a later `rm` in
a different script cannot shrink an earlier layer. This is why cleanup must
be inline (see [adding-tools.md](adding-tools.md#cleanup)).

## The build-script pipeline

The final stage runs these scripts, in this order:

| Order | Script                          | Responsibility                                                                                              |
| ----- | ------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1     | `build/10-tools.sh`             | `apt install` everything in the inline `PACKAGES=(...)` array. Prefer this when a tool is packaged for Kali. |
| 2     | `build/20-manual-installs.sh`   | On-network / AD tools not in apt: GitHub releases, `git clone`, `pipx`, `gem`, etc. **New non-apt AD/network tools go here.** |
| 3     | `build/25-aws-tools.sh`         | AWS cloud tooling.                                                                                          |
| 4     | `build/26-azure-tools.sh`       | Azure / Entra ID cloud tooling.                                                                             |
| 5     | `build/27-kubernetes-tools.sh`  | Kubernetes cloud tooling.                                                                                   |
| 6     | `build/28-docker-iac-tools.sh`  | Docker / container-registry and IaC static-analysis tooling.                                               |
| 7     | `build/29-multicloud-tools.sh`  | Tools that cover more than one provider (prowler, cloud_enum, cloudsploit, ScoutSuite).                     |
| 8     | `build/30-config.sh`            | Locale, login, readline tweaks; runs the neovim plugin install.                                            |
| 9     | `build/40-wordlists.sh`         | Extra wordlists and seclists massaging.                                                                    |

`build/00-go-installs.sh` is **not** in this list — it runs only in the
builder stage (stage 1), never in the final image.

### Cloud-script ordering is load-bearing

The per-provider scripts run in a fixed order for a reason:
**`26-azure-tools.sh` must run before `27-kubernetes-tools.sh`** because
the Kubernetes script runs `az aks install-cli` (to get kubelogin), which
needs the `az` CLI that the Azure script installs. Don't reorder these.

### The builder script (`build/00-go-installs.sh`)

Runs in stage 1 only. Installs golang + build deps, then builds each Go
tool with `-ldflags="-s -w"` and compiles `kics`.

## The `COPY --from=builder` contract

This is the single most common way to break this image, so it gets its own
section.

There is **no wildcard copy** from the builder stage. Every binary
compiled in `00-go-installs.sh` needs its own explicit line in the
`Containerfile`:

```dockerfile
COPY --from=builder /usr/local/bin/cloudfox /usr/local/bin/cloudfox
```

If you add a tool to `00-go-installs.sh` and forget the matching `COPY`
line, **the build still succeeds**. Nothing errors. The tool is compiled,
the builder stage is discarded, and the tool is simply absent from the
shipped image. The only symptom is someone reporting `command not found`
weeks later.

The inverse also fails, and fails loudly: a `COPY --from=builder` line
naming a binary that `00-go-installs.sh` does not actually produce aborts
the build with a missing-file error.

To audit both directions at once, compare what the builder installs
against what the `Containerfile` copies:

```bash
comm -23 \
  <(grep -oP '(?<=^install -o root -g root -m 0755 )\S+ \S+' build/00-go-installs.sh \
      | awk '{print $2}' | xargs -n1 basename | sort) \
  <(grep -oP '(?<=^COPY --from=builder )\S+' Containerfile \
      | xargs -n1 basename | sort)
```

Any name printed is built but never copied — i.e. silently missing from
the image.

## Config vendoring

`config/` holds the shell/editor/multiplexer configuration, vendored
**inline in the repo** (no git submodule) and baked into `/root` during
the final stage:

| Source                         | Destination in image      | Purpose                                                        |
| ------------------------------ | ------------------------- | -------------------------------------------------------------- |
| `config/bashrc`                | `/root/.bashrc`           | Main bash config. Sources every file in `~/.bashrc.d/`.        |
| `config/bashrc.d/`             | `/root/.bashrc.d/`        | `aliases` (nmap/util functions) **and** `cloud` (AWS/Kubernetes/Azure aliases, functions, and cloud env — krew PATH, `SYSTEMD_PAGER`, aws/az completion). |
| `config/bash-color-prompt.sh`  | `/etc/profile.d/`         | Colored prompt.                                                |
| `config/nvim/`                 | `/root/.config/nvim/`     | Neovim config + `install-plugins.sh` (run by `30-config.sh`).  |
| `config/tmux.conf`             | `/root/.tmux.conf`        | tmux config.                                                   |
| `config/tmux/`                 | `/root/.tmux/`            | tmux plugins.                                                  |

### The `.bashrc.d/` mechanism

`~/.bashrc` sources **every** file in `~/.bashrc.d/`. This directory
receives two kinds of file:

1. The vendored `config/bashrc.d/*` files (`aliases`, `cloud`) copied in at
   build time.
2. Per-tool `.rc` files written **during** the build by the install
   scripts for run-as-script tools (see
   [adding-tools.md](adding-tools.md)).

Both are auto-sourced at container startup, so any alias or function
dropped into `/root/.bashrc.d/*.rc` during the build is available in the
running container with no further wiring.
