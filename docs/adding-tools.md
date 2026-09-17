# Adding tools

This is the decision tree for adding a new tool to the image. Pick the
path that matches the tool; each path has a fixed pattern that the rest of
the repo already follows — match it exactly.

**GCP / gcloud is excluded from this image. Do not add it.**

## Where does the tool go?

```
Is the tool packaged for Kali (apt)?
├─ Yes → add to the PACKAGES=(...) array in build/10-tools.sh
└─ No  → Is it a compiled Go / native tool?
         ├─ Yes → build/00-go-installs.sh (builder stage) + COPY --from=builder
         └─ No  → which script? (see "Which script" below)
                  ├─ Python, pip-installable package → pipx
                  └─ Python, run-as-script only      → /opt/<tool>/venv + alias
                  └─ Prebuilt release binary          → wget/curl + install
```

### Which script does a non-apt, non-Go tool belong in?

- On-network / Active Directory tool → `build/20-manual-installs.sh`
- AWS-specific → `build/25-aws-tools.sh`
- Azure / Entra ID-specific → `build/26-azure-tools.sh`
- Kubernetes-specific → `build/27-kubernetes-tools.sh`
- Docker / container-registry / IaC static analysis → `build/28-docker-iac-tools.sh`
- Covers more than one cloud provider → `build/29-multicloud-tools.sh`

Add the tool to the file matching what it does. If a script needs the
version-pinning helper, add `source /build/helper_functions` near the top
(after `set -eoux pipefail`) if it isn't already there.

## apt tools → `build/10-tools.sh`

If the tool is in the Kali repos, just add its package name to the
`PACKAGES=(...)` array. This is the cheapest and most maintainable path —
always prefer it when available.

## Compiled Go / native tools → `build/00-go-installs.sh`

Go and other compiled tools are built in the **builder stage** so the
toolchain never ships. Add the tool to `build/00-go-installs.sh`, matching
the existing `-ldflags="-s -w"` stripping:

```bash
# mytool
go install -ldflags="-s -w" github.com/owner/mytool@latest
install -o root -g root -m 0755 /root/go/bin/mytool /usr/local/bin/mytool
```

Then add the matching copy line to the `Containerfile`, in the
`COPY --from=builder` block:

```dockerfile
COPY --from=builder /usr/local/bin/mytool /usr/local/bin/mytool
```

> **Both steps are mandatory.** A binary compiled in the builder stage but
> never `COPY --from=builder`'d is built and then thrown away — it will be
> absent from the shipped image with no error. If you move an existing tool
> from apt/release into the builder stage, also delete its old apt/release
> install line so it isn't installed twice.

## Python tools

The path depends on whether the tool is a pip-installable package — i.e.
whether it ships a `setup.py`/`pyproject.toml` that declares **console
entry points**.

### Packaged tool → `pipx`

Use `pipx` for anything that exposes its own console script(s):

```bash
pipx install <pypi-name>
# or, to track latest from git:
pipx install git+https://github.com/<owner>/<repo>
```

- pipx puts each tool in its own isolated venv and exposes its commands in
  `~/.local/bin`, which `.bashrc` already has on `PATH`.
- Extra dependencies go in with `pipx inject <tool> <dep>`.
- pipx **refuses** packages that expose no console scripts of their own —
  if it errors with that, install the package that actually ships the
  command, or use the run-as-script path below.
- Do **not** create `/opt/<tool>/venv` for these.

Examples already on this path: `netexec`, `pre2k`, `pywhisker`,
`bloodyAD`, `adidnsdump`, `powerhub`; and cloud tools like `prowler`,
`pacu`, `checkov`, `scoutsuite`.

**impacket** is a special case: it is `pipx install`ed, and pipx exposes
its example scripts on `PATH` in `~/.local/bin` **keeping** the `.py`
suffix — so you invoke `secretsdump.py`, `wmiexec.py`, etc. No symlink loop
is needed.

### Run-as-script tool → `/opt/<tool>/venv` + alias

Tools that only ship a `requirements.txt` (no entry points) can't be
pipx-installed. Use the legacy venv-and-alias pattern:

```bash
git clone https://github.com/<owner>/<tool> /opt/<tool>
python3 -m venv /opt/<tool>/venv
/opt/<tool>/venv/bin/pip install --no-cache-dir -r /opt/<tool>/requirements.txt
echo "alias <name>=\"/opt/<tool>/venv/bin/python /opt/<tool>/<script>.py\"" > /root/.bashrc.d/<name>.rc
```

The `.rc` file in `/root/.bashrc.d/` is auto-sourced by `.bashrc` at
container startup (see
[architecture.md](architecture.md#the-bashrcd-mechanism)).

Examples already on this path: `sccmhunter`, `eavesarp`, `dnscan`,
`jwt_tool`, `PCredz`, `krbrelayx`; and cloud tools like `snotra_azure`,
`kubenumerate`, `KubiScan`, `kubernetes-rbac-audit`.

## Prebuilt release binaries

For tools shipped as a prebuilt binary/archive on a GitHub release:

```bash
wget -q "<release-url>" -O /opt/<tool>
install -o root -g root -m 0755 /opt/<tool> /usr/local/bin/<tool>
rm /opt/<tool>
```

**Do not hardcode the version** in the URL. Use the version-pinning helper
below.

## Version pinning: `ghcurl` + `curl_latest_release`

To avoid hardcoding release versions (which silently rot until someone
notices the image ships an ancient tool), the install scripts use a shared
helper to resolve the latest release tag at build time.

### The pieces

- **`build/ghcurl`** — a thin `curl` wrapper for the GitHub API. It reads a
  token from `/run/secrets/GITHUB_TOKEN` (a podman secret mount) and adds
  an `Authorization: Bearer` header when present; otherwise it falls back
  to unauthenticated requests. Everything in `build/` is copied to `/build`
  in the image, so scripts call it as `/build/ghcurl`.
- **`build/helper_functions`** — sourced by the build scripts. Defines:

  ```bash
  curl_latest_release(){
      /build/ghcurl "https://api.github.com/repos/$1/releases" \
          | jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name' \
          | grep -E '^v?[0-9]+\.[0-9]+(\.[0-9]+)?$' \
          | head -1
  }
  ```

### How to use it

At the top of the build script (after `set -eoux pipefail`), if not
already present:

```bash
source /build/helper_functions
```

Then, per tool:

```bash
# mytool
MYTOOL_VERSION=$(curl_latest_release owner/mytool)
wget -q "https://github.com/owner/mytool/releases/download/${MYTOOL_VERSION}/mytool-linux-amd64" -O /opt/mytool
install -o root -g root -m 0755 /opt/mytool /usr/local/bin/mytool
rm /opt/mytool
```

If the **asset filename** embeds the version without the leading `v`
(e.g. `kubeaudit_0.22.2_linux_amd64.tar.gz` for tag `v0.22.2`), strip the
`v` for the filename while keeping the full tag in the URL path:

```bash
MYTOOL_VERSION=$(curl_latest_release owner/mytool)
MYTOOL_VERSION_NUM="${MYTOOL_VERSION#v}"
wget -q "https://github.com/owner/mytool/releases/download/${MYTOOL_VERSION}/mytool_${MYTOOL_VERSION_NUM}_linux_amd64.tar.gz" \
    -O "/opt/mytool_${MYTOOL_VERSION_NUM}_linux_amd64.tar.gz"
```

Tools already on this helper: `titus` (`20-manual-installs.sh`),
`kubeaudit` and `kubeletctl` (`27-kubernetes-tools.sh`), `regctl`
(`28-docker-iac-tools.sh`).

### Why `.tag_name` and not `.name`, and why the filters

- The helper reads **`.tag_name`**, not `.name`. Many projects set `.name`
  to a human title (`"BloodHound CLI v0.2.1"`, `"RunasCs version 1.5"`)
  that is useless as a version string; `.tag_name` is the reliable field.
- `select(.draft == false and .prerelease == false)` skips drafts and
  betas/RCs — GitHub's `/releases` endpoint includes them by default, and
  without this filter `head -1` could latch onto a `-rc1` tag.
- The regex `^v?[0-9]+\.[0-9]+(\.[0-9]+)?$` accepts both `v`-prefixed and
  bare tags, and both 2- and 3-part versions. It is **strict on purpose**:
  a project with an unusual tag format will not match, and should keep its
  own working install logic rather than being forced through this helper.

### When *not* to convert a tool to the helper

Leave a tool alone if it already avoids a hardcoded version by other
means — e.g. GitHub's `/releases/latest/download/...` URL shortcut,
`go install ...@latest`, a `dl.k8s.io/.../stable.txt`-style pointer, or an
upstream self-updating install script. Two live examples in this repo:

- **`azqr`** (`26-azure-tools.sh`) uses tags of the form `v.4.1.1` (a
  literal dot after `v`), which the helper's regex intentionally rejects.
  It already resolves its own latest tag via `/releases/latest` + `jq`, so
  it is left as-is.
- **`kubectl`**, **`krew`**, **`taws`**, and **`grype`** all track latest
  through upstream mechanisms already — don't reshape them.

## Cleanup

Because each build script is a **single `RUN` layer**
(see [architecture.md](architecture.md#the-mount-flags-on-each-run)), any
downloaded archive or clone leftover that isn't removed **in the same
script** is baked permanently into that layer. A later `rm` in a different
script cannot reclaim the space.

So: remove tarballs/zips/clone leftovers inline, right after you've
installed from them — as every existing block already does.
