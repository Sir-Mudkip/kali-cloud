# Documentation

Reference documentation for the `kali-cloud` container image build. Read
these before making changes to the build.

- **[architecture.md](architecture.md)** — what the repo produces, the
  two-stage `Containerfile`, the ordered build-script pipeline (including
  the per-provider cloud scripts and why their order matters), and how
  `config/` is baked into the image. Start here.
- **[adding-tools.md](adding-tools.md)** — the decision tree for adding a
  new tool (apt vs. pipx vs. venv-and-alias vs. Go builder stage), which
  cloud script a tool belongs in, and the `ghcurl` / `curl_latest_release`
  helper for pinning to the latest GitHub release instead of a hardcoded
  version.
- **[ci-cd.md](ci-cd.md)** — the GitHub Actions workflows: build →
  rechunk → push → sign, the weekly rebuild and image-retention cron, and
  the `just chunk` recipe for reproducing the rechunk step locally.

The behavioural rules for agents working in this repo live in the
repo-root [`CLAUDE.md`](../CLAUDE.md).
