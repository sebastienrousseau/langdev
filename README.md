<!-- SPDX-License-Identifier: Apache-2.0 OR MIT -->

<p align="center">
  <img src="https://cloudcdn.pro/langdev/v1/logos/langdev.svg" alt="langdev logo" width="128" />
</p>

<h1 align="center">langdev</h1>

<p align="center">
  Portable, disposable per-language development containers — a shared,
  hardened core that builds with <b>both</b> Docker and Podman and boots
  the developer's own dotfiles.
</p>

<p align="center">
  <a href="https://github.com/sebastienrousseau/langdev/actions"><img src="https://img.shields.io/github/actions/workflow/status/sebastienrousseau/langdev/ci.yml?style=for-the-badge&logo=github" alt="Build" /></a>
  <a href="#license"><img src="https://img.shields.io/badge/license-Apache--2.0%20OR%20MIT-blue?style=for-the-badge" alt="License: Apache-2.0 OR MIT" /></a>
  <a href="https://scorecard.dev/viewer/?uri=github.com/sebastienrousseau/langdev"><img src="https://img.shields.io/ossf-scorecard/github.com/sebastienrousseau/langdev?style=for-the-badge&label=OpenSSF%20Scorecard&logo=openssf" alt="OpenSSF Scorecard" /></a>
  <a href="#portability"><img src="https://img.shields.io/badge/engines-docker%20%7C%20podman-1d63ed?style=for-the-badge&logo=docker" alt="Engines: Docker or Podman" /></a>
  <a href="#portability"><img src="https://img.shields.io/badge/arch-amd64%20%C2%B7%20arm64-555?style=for-the-badge" alt="Architectures: amd64, arm64" /></a>
</p>

---

## Contents

**Getting started**

- [Quick start](#quick-start) — clone a `<language>dev` repo, `make up`, done
- [The suite](#the-suite) — `langdev` core plus the per-language images

**Design**

- [Why this approach?](#why-this-approach) — the four choices that shape everything
- [Architecture](#architecture) — what lives here, what each repo vendors
- [The developer environment IS your dotfiles](#the-developer-environment-is-your-dotfiles) — no synthetic config

**Operational**

- [Security model](#security-model) — the container threat model and controls
- [Portability](#portability) — engines, architectures, host assumptions
- [When not to use langdev](#when-not-to-use-langdev) — limitations, stated plainly
- [Development](#development) — `make` targets, lint, scan, SBOM, CI
- [Documentation](#documentation) — community docs and the house style
- [License](#license)

---

## Quick start

Each `<language>dev` repo is standalone. Clone one, and one command
gets you an interactive, hardened shell in a fresh container:

```sh
git clone https://github.com/sebastienrousseau/rustdev.git
cd rustdev
make up          # builds the image, then drops you into a dev shell
```

`make up` builds for the host architecture and runs the container
non-root, read-only, with all capabilities dropped (see
[Security model](#security-model)). Your project directory is the only
bind mount, at `/work`. When you are done:

```sh
make trash       # remove the image and dangling build cache
```

No registry pull, no base-image dependency, no network needed on first
launch — the image is built entirely from the repo you cloned.

---

## The suite

`langdev` is the shared foundation for a family of **`<language>dev`**
images. Each image is a complete, batteries-included toolchain for one
language, in a container you can spin up and throw away in seconds.

| Repo | Language stack | Built on |
|---|---|---|
| **`langdev`** | The shared core: hardening, entrypoint, dotfiles bootstrap, `Containerfile`/`compose`/`Makefile` templates | — (this repo) |
| **`rustdev`** | rustup toolchain, rust-analyzer, clippy, cargo-audit | `langdev` core |
| **`pythondev`** | CPython, uv, ruff, mypy, pytest, debugpy | `langdev` core |
| **`llamadev`** | Ollama runtime + Python LLM tooling | `langdev` core |

Everything language-agnostic lives in this repo and is **vendored** into
each `<language>dev` repo under `common/`, kept in sync with
`make sync-common`. Each repo is therefore **standalone-buildable** —
clone one, `make up`, done.

---

## Why this approach?

Most "dev container" setups make one of two trades: they are either a
heavyweight, root-running image with the kitchen sink, or a minimal base
that leaves you to reassemble your own editor, shell, and tools every
time. langdev refuses both. Four choices, in priority order, shape every
image in the suite:

1. **Secure by default, not by opt-in.** The container runs as a
   non-root `dev` user (UID/GID 1000) with **all Linux capabilities
   dropped**, `no-new-privileges`, and a **read-only root filesystem**;
   writable state is confined to explicit `tmpfs` mounts. This is the
   default `make up` posture, not a hardened variant you have to
   remember to select. The threat model is [documented](SECURITY.md),
   not implied.

2. **Ultra-small but complete.** Multi-stage builds on an Alpine base
   ship only the runtime a developer actually needs for that language —
   compiler/interpreter, LSP, formatter, test runner, editor — and
   nothing else. "Complete" is measured against a real workflow, not a
   feature list: you can edit, build, test, and debug without reaching
   outside the container.

3. **Portable and disposable.** One OCI `Containerfile` builds with
   Docker, Podman, Buildah, and nerdctl. The `Makefile` auto-detects the
   engine and adjusts flags (SELinux `:Z` mounts, userns) accordingly.
   Images are multi-arch (`linux/amd64`, `linux/arm64`). There are no
   host assumptions — the only bind mount is your project at `/work`,
   and `make trash` leaves nothing behind.

4. **Reliable and reproducible.** Everything is pinned: the base image
   **by digest**, toolchain versions, OS packages, Neovim plugins via
   `lazy-lock.json`, and language dependencies via hash-locked
   lockfiles. Downloaded binaries are **checksum-verified** — there is
   no `curl | sh` anywhere in the build. Pin `DOTFILES_REF` to a tag or
   commit and a build is byte-reproducible.

The pay-off of the vendoring model in choice 3 is worth stating: because
`common/` is copied into each repo rather than pulled from a registry,
there is no "base image drift" and no supply-chain hop at build time. A
`<language>dev` repo is a complete, auditable unit on its own.

---

## Architecture

This repo is the single source of truth. Language-agnostic pieces live
here and are vendored into each `<language>dev` repo:

```
langdev/                       # this repo — single source of truth
├── common/
│   ├── bootstrap-dotfiles.sh  # build-time: clone + chezmoi-apply the
│   │                          #   user's dotfiles (latest by default)
│   └── entrypoint.sh          # strict-mode, tmux-loading, signal-safe
├── templates/                 # per-repo scaffolding
│   ├── Containerfile          # multi-stage, hardened, parameterised
│   ├── compose.yaml           # fully hardened service definition
│   ├── Makefile               # docker|podman autodetect lifecycle
│   ├── env.example            # placeholders only — never real secrets
│   ├── dockerignore / gitignore
│   └── github-workflows/ci.yml
└── bin/langdev-sync           # copies common/ into a target repo
```

Each `<language>dev` repo adds only the thin, language-specific layer:

- a **toolchain stage** in its `Containerfile` — the language
  compiler/interpreter plus its LSP/formatter/test tools, installed at
  build time into a relocatable `/opt/langdev/toolchain`,
- **one** `nvim/plugins.local/lang.lua` — the language's LSP spec,
- **one** `dotfiles.d/<lang>.sh` installed to
  `/etc/profile.d/<lang>.sh` — the language `PATH`/env for login shells,
  kept **out** of the user's dotfiles so those stay pristine and
  langdev-agnostic,
- language-specific `env.example` / README entries.

### The developer environment IS your dotfiles

langdev does **not** ship a synthetic shell or editor config. At build
time each image clones the user's chezmoi-managed **dotfiles repo** and
runs `chezmoi apply`, so the container has the *real* bashrc, aliases,
tmux config, and Neovim setup — **always the latest** by default. Pin
`DOTFILES_REF` to a tag or commit for reproducible builds.

- **tmux** is installed and **loaded by default**: the entrypoint
  attaches to (or creates) a persistent `langdev` tmux session for
  interactive shells. Opt out with `LANGDEV_NO_TMUX=1`.
- The dotfiles' Neovim config is authoritative. Each `<language>dev`
  image drops **one** `nvim/plugins.local/lang.lua` spec into the
  dotfiles' nvim (auto-imported via its `plugins.local` convention) to
  wire that language's LSP. Plugins are baked headless at build time, so
  the container needs **no network on first launch**.

---

## Security model

Applies to every image in the suite. The full threat model and the
private disclosure process are in [`SECURITY.md`](SECURITY.md).

- **Non-root.** Runs as `dev` (UID/GID 1000); no `sudo`, no setuid
  binaries in the image.
- **Least privilege at runtime.** Compose enforces `cap_drop: [ALL]`,
  `security_opt: [no-new-privileges:true]`, `read_only: true` (with
  `tmpfs` for `/tmp` and `/home/dev/.cache`), plus `pids_limit` and
  `mem_limit`. `make up` applies the same flags on the CLI.
- **Pinned, checksummed inputs.** Base image pinned **by digest**; OS
  packages pinned; toolchains and downloaded binaries
  **checksum-verified** — never `curl | sh`.
- **Hash-locked dependencies.** Language dependencies install from
  hash-pinned lockfiles.
- **No committed secrets.** No `.env` is committed or `COPY`'d into an
  image — secrets are runtime-only via `env_file`. `.dockerignore` and
  `.gitignore` block `.env` from both the build context and git.
- **CI gates every change.** `hadolint`, `shellcheck`, and a Trivy image
  scan (fail on HIGH/CRITICAL) run on every push; an SBOM is generated
  on release.

Report a vulnerability privately — see [`SECURITY.md`](SECURITY.md). Do
not open a public issue.

---

## Portability

- **One `Containerfile` (OCI).** `docker build`, `podman build`,
  `buildah`, and `nerdctl` all work from the same file.
- **Engine autodetection.** The `Makefile` detects `docker` or `podman`
  and adjusts flags (SELinux `:Z` mounts, userns) accordingly.
- **Multi-arch.** Images build for `linux/amd64` and `linux/arm64` via
  `docker buildx` / `podman --platform`.
- **No host assumptions.** The only bind mount is your project directory
  at `/work`.

---

## When not to use langdev

Stated plainly, so you can rule it out fast:

- **You need a production runtime image.** langdev builds *development*
  environments — editor, LSP, test tooling, a shell. It is deliberately
  not a minimal production artifact; ship a separate, slimmer image for
  that.
- **You do not use chezmoi-managed dotfiles.** The environment *is* the
  user's dotfiles. Without a chezmoi dotfiles repo you lose the main
  point, though the hardening and toolchain layers still stand on their
  own.
- **You need GPU passthrough or host-device access.** The default
  posture drops all capabilities and forbids privilege escalation.
  Workloads that need device access require deliberate, documented
  relaxations that run against the grain of the design.
- **You are on a platform without Docker or Podman.** There is no
  VM-less fallback; the suite targets an OCI engine on Linux, macOS, or
  Windows/WSL2.

---

## Development

This repo ships the templates and the shared core; per-repo `Makefile`s
expose the lifecycle. The common targets:

```sh
make up          # build + interactive dev shell (alias: make shell)
make run CMD=… # one-shot command in a fresh container
make build       # build the image for the host arch
make buildx      # multi-arch build (linux/amd64, linux/arm64)
make test        # bats unit tests under kcov, fail if coverage < 95%
make coverage    # alias for test; HTML report in coverage/
make lint        # hadolint the Containerfile + shellcheck the scripts
make scan        # Trivy vulnerability scan (fail on HIGH/CRITICAL)
make sbom        # CycloneDX SBOM via syft
make trash       # remove the image and dangling build cache
make sync-common # refresh common/ from the langdev source
```

### Tests and coverage

The shared shell core (`common/bootstrap-dotfiles.sh`,
`common/entrypoint.sh`, `bin/langdev-sync`) is unit-tested with
[bats-core](https://github.com/bats-core/bats-core) and measured with
[kcov](https://github.com/SimonKagstrom/kcov). `make test` runs the
suite under kcov and **fails below 95 % line coverage**. The tests are
hermetic — `git`, `chezmoi`, `nvim`, `tmux`, and `rsync` are test
doubles on a closed `PATH`, so no network or container is needed. See
[`test/README.md`](test/README.md) for the layout and the (production-inert)
`LANGDEV_TEST` seam.

### CI and security workflows

Copied from [`templates/github-workflows/`](templates/github-workflows/)
into each repo's `.github/workflows/`:

| Workflow | What it gates |
|---|---|
| `ci.yml` | shellcheck, hadolint, **bats + kcov coverage (≥95 %)**, docker build, Trivy image scan (fail HIGH/CRITICAL), CycloneDX SBOM |
| `scorecard.yml` | OpenSSF Scorecard, results published + SARIF to code-scanning |
| `sast.yml` | ShellCheck + Trivy config + Checkov, SARIF → code-scanning |
| `dependency-review.yml` | dependency + action changes reviewed on every PR |

All actions are pinned to a full commit SHA, and every workflow runs
least-privilege (`permissions: contents: read`, escalated per-job only
where a SARIF upload needs `security-events: write`). The OpenSSF
Best-Practices self-assessment lives in
[`doc/CII-BEST-PRACTICES.md`](doc/CII-BEST-PRACTICES.md); a maintainer can
apply the branch-protection ruleset with
[`scripts/set-branch-protection.sh`](scripts/set-branch-protection.sh).

Contributions require signed commits and Conventional Commit messages —
see [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## Documentation

| Document | What it covers |
|---|---|
| [`STYLE.md`](STYLE.md) | The house style every suite README follows — skeleton, badges, tone, SPDX, licensing. |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | The container workflow: build/lint/test/scan/sbom, signed commits, Conventional Commits. |
| [`test/README.md`](test/README.md) | The bats + kcov unit-test suite, the hermetic test doubles, and the coverage gate. |
| [`doc/CII-BEST-PRACTICES.md`](doc/CII-BEST-PRACTICES.md) | OpenSSF Best-Practices self-assessment: every criterion mapped to evidence, honest GAPs. |
| [`SECURITY.md`](SECURITY.md) | The container threat model and the private disclosure process. |
| [`GOVERNANCE.md`](GOVERNANCE.md) | Who decides what, and how the maintainer base is meant to grow. |
| [`SUPPORT.md`](SUPPORT.md) | Where to go for questions, bugs, and feature requests. |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Community standards and enforcement. |
| [`CHANGELOG.md`](CHANGELOG.md) | Notable changes, Keep a Changelog format. |

---

## License

Licensed under either of

- Apache License, Version 2.0 ([`LICENSE-APACHE`](LICENSE-APACHE))
- MIT license ([`LICENSE-MIT`](LICENSE-MIT))

at your option. The suite is dual-licensed `Apache-2.0 OR MIT`; every
file carries an `SPDX-License-Identifier: Apache-2.0 OR MIT` header.

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms
or conditions.
