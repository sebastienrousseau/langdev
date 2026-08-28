<!-- SPDX-License-Identifier: MIT -->

# langdev — portable, disposable development environments

`langdev` is the shared foundation for a suite of **`<language>dev`**
container images (e.g. `rustdev`, `pythondev`, `llamadev`). Each image
gives you a complete, batteries-included toolchain for one language,
inside a container you can **spin up and throw away in seconds** — on
any machine with Docker or Podman (Linux, macOS, Windows/WSL2).

Design goals, in priority order:

1. **Secure by default** — non-root, all capabilities dropped,
   `no-new-privileges`, read-only root filesystem, pinned & checksummed
   inputs, no committed secrets, reproducible builds.
2. **Ultra-small but complete** — multi-stage builds, Alpine base,
   only the runtime a developer actually needs for that language
   (compiler/interpreter + LSP + formatter + test runner + editor).
3. **Portable & disposable** — one OCI `Containerfile` that builds with
   **both** Docker and Podman, multi-arch (`linux/amd64`, `linux/arm64`),
   no host assumptions, `make up` / `make trash` lifecycle.
4. **Reliable & reproducible** — everything pinned (base image by
   digest, toolchain versions, OS packages, Neovim plugins via
   `lazy-lock.json`, language deps via hash-locked lockfiles).

## The suite

| Repo | Language stack | Base |
|---|---|---|
| `rustdev` | rustup toolchain, rust-analyzer, clippy, cargo-audit | `langdev` core |
| `pythondev` | CPython, uv, ruff, mypy, pytest, debugpy | `langdev` core |
| `llamadev` | Ollama runtime + Python LLM tooling | `langdev` core |

## Architecture

Everything language-agnostic lives here and is **vendored** into each
`<language>dev` repo under `common/` (kept in sync with
`make sync-common`). Each repo is therefore **standalone-buildable** —
clone one repo, `make up`, done. No registry or base-image pull needed.

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

### The developer environment IS the user's own dotfiles

langdev does **not** ship a synthetic shell/editor config. At build time
each image clones the user's chezmoi-managed **dotfiles repo** and runs
`chezmoi apply`, so the container has the *real* bashrc, aliases, tmux
config, and Neovim setup — **always the latest** by default (pin a
tag/commit with the `DOTFILES_REF` build arg for reproducible builds).

- **tmux** is installed and **loaded by default**: the entrypoint
  attaches to (or creates) a persistent `langdev` tmux session for
  interactive shells. Opt out with `LANGDEV_NO_TMUX=1`.
- The dotfiles' Neovim config is authoritative. Each `<language>dev`
  image drops **one** `nvim/plugins.local/lang.lua` spec into the
  dotfiles' nvim (auto-imported via its `plugins.local` convention) to
  wire that language's LSP. Plugins are baked headless at build time, so
  the container needs **no network on first launch**.

Each `<language>dev` repo therefore adds only:

- a thin **toolchain stage** in its `Containerfile` (the language
  compiler/interpreter + its LSP/formatter/test tools, installed at
  build time into a relocatable `/opt/langdev/toolchain`),
- **one** `nvim/plugins.local/lang.lua` (its LSP spec),
- **one** `dotfiles.d/<lang>.sh` installed to `/etc/profile.d/<lang>.sh`
  (language `PATH`/env for login shells — kept OUT of the user's
  dotfiles so those stay pristine and langdev-agnostic),
- language-specific `env.example` / README entries.

## Security model (applies to every image)

- Runs as non-root `dev` (UID/GID 1000); no `sudo`, no setuid binaries.
- Compose enforces `cap_drop: [ALL]`, `security_opt:
  [no-new-privileges:true]`, `read_only: true` (with tmpfs for
  `/tmp`, `/home/dev/.cache`), `pids_limit`, `mem_limit`.
- Base image pinned **by digest**; OS packages pinned; toolchains and
  downloaded binaries **checksum-verified** (no `curl | sh`).
- Language dependencies installed from **hash-pinned lockfiles**.
- No `.env` is committed or `COPY`'d into an image — secrets are
  runtime-only via `env_file`. `.dockerignore` and `.gitignore` block
  `.env` from both the build context and git.
- CI gates every change with `hadolint`, `shellcheck`, and a Trivy
  image scan; an SBOM is generated on release.

## Portability

- One `Containerfile` (OCI) → `docker build`, `podman build`,
  `buildah`, `nerdctl` all work.
- `Makefile` auto-detects `docker` or `podman` and adjusts flags
  (SELinux `:Z` mounts, userns) accordingly.
- Multi-arch images via `docker buildx` / `podman --platform`.
- No host-path assumptions; the only bind mount is your project
  directory at `/work`.

## License

MIT — see [`LICENSE`](LICENSE).
