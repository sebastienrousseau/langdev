<!-- SPDX-License-Identifier: Apache-2.0 OR MIT -->

# Changelog

All notable changes to this project are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.3] - 2026-08-29

### Added

- **Model Context Protocol (MCP) Server Suite.**
  - Added `common/mcp-server.sh` implementing JSON-RPC 2.0 stdio transport exposing workspace tools (`list_files`, `read_file`, `git_status`, `git_diff`, `run_tests`, `run_command`) to AI coding agents.
  - Added `common/mcp.json` configuration template for Claude Code, Cursor, and Aider.
- **AI Context Packing (`ai-pack`).**
  - Added `common/ai-pack.sh` for fast, token-efficient XML and Markdown codebase bundling respecting `.gitignore`.
- **Local LLM Routing.**
  - Added automatic resolution for local Ollama instances (`http://host.containers.internal:11434`).
- **Bats Unit Tests.**
  - Added `test/mcp.bats` and `test/ai-pack.bats`.

## [0.0.2] - 2026-08-29

### Added

- **Remote & Mobile Web Access.**
  - `make web` and `make web-auth` targets using `ttyd` for browser-based access on iPads and mobile devices over WebSocket/SSL.
  - `make mosh` for UDP-based roaming mobile shell sessions that survive connection drops.
- **Diagnostic CLI (`make doctor`).**
  - Added `common/doctor.sh` to probe host engines, architecture, cgroups, kernel security, and clipboard readiness.
- **Universal Clipboard (OSC 52).**
  - Added `set -s set-clipboard on` in `common/tmux.conf` for seamless copy-paste to host/mobile clipboards.
- **TUI Popups.**
  - Added floating TMUX popups for Lazygit (`Prefix + g`) and Lazydocker (`Prefix + d`).
- **VS Code IDE Grid & Parallel Task Worktrees.**
  - Added `common/tmux-ide.sh` (`Prefix + i`) and `common/muxtree.sh` (`Prefix + m`).

## [0.0.1] - 2026-08-29

The initial langdev suite: a shared, hardened core for a family of
portable, disposable per-language development containers
(`<language>dev` — `rustdev`, `pythondev`, `llamadev`, …) that build
with **both** Docker and Podman and boot the developer's own
chezmoi-managed dotfiles.

### Added

- **Shared core (`common/`).**
  - `entrypoint.sh` — strict-mode, signal-safe, non-root entrypoint that
    attaches to (or creates) a persistent `langdev` tmux session for
    interactive shells (`LANGDEV_NO_TMUX=1` opts out).
  - `bootstrap-dotfiles.sh` — build-time clone + `chezmoi apply` of the
    user's dotfiles repo, latest by default, pinnable via `DOTFILES_REF`
    for reproducible builds.
- **Templates (`templates/`).** A parameterised, multi-stage
  `Containerfile`; a fully hardened `compose.yaml`; a `Makefile` with
  docker/podman autodetection; `env.example` (placeholders only);
  `dockerignore` / `gitignore`; and a `github-workflows/ci.yml`.
- **`bin/langdev-sync`** — vendors `common/` into a `<language>dev`
  repo, so each repo is standalone-buildable with no registry or
  base-image pull.
- **Security posture, on by default.** Non-root `dev` (UID/GID 1000);
  `cap_drop: [ALL]`; `no-new-privileges`; read-only root filesystem with
  `tmpfs` for writable state; `pids_limit` and `mem_limit`; base image
  pinned by digest; checksum-verified downloads (no `curl | sh`);
  hash-locked language lockfiles; no committed or baked-in secrets.
- **CI gates.** `hadolint`, `shellcheck`, and a Trivy image scan
  (fail on HIGH/CRITICAL) on every push and pull request; a CycloneDX
  SBOM generated on release.
- **`make` lifecycle.** `build`, `buildx` (multi-arch: `linux/amd64`,
  `linux/arm64`), `up`/`shell`, `run`, `lint`, `scan`, `sbom`, `trash`,
  and `sync-common`.

### Documentation

- Suite README, and the [`STYLE.md`](STYLE.md) house-style spec every
  suite README follows (skeleton, badge set, tone, SPDX, licensing).
- Community docs: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md),
  [`CONTRIBUTING.md`](CONTRIBUTING.md), [`SECURITY.md`](SECURITY.md),
  [`SUPPORT.md`](SUPPORT.md), [`GOVERNANCE.md`](GOVERNANCE.md).
- `.github/` scaffolding: `CODEOWNERS`, `FUNDING.yml`, `dependabot.yml`
  (github-actions + docker ecosystems), a pull-request template, and
  issue forms (bug report, feature request, plus a config routing
  questions and security reports).

### Licensing

- Relicensed the suite from single MIT to **dual `Apache-2.0 OR MIT`**.
  Added `LICENSE-APACHE` and `LICENSE-MIT`, removed the single `LICENSE`
  file, and applied `SPDX-License-Identifier: Apache-2.0 OR MIT` headers
  across the suite.

[Unreleased]: https://github.com/sebastienrousseau/langdev/commits/main
