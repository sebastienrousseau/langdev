<!-- SPDX-License-Identifier: Apache-2.0 OR MIT -->

# langdev house style

This is the spec every README in the langdev suite follows —
`langdev` itself and each `<language>dev` repo (`rustdev`,
`pythondev`, `llamadev`, …). It exists so the suite reads as one
project: same skeleton, same badge row, same tone, same
licensing and SPDX conventions in every repo.

The rule of thumb: a reader who has seen one suite README should
be able to find the same information in the same place in any
other. Deviate only where the language genuinely demands it, and
say why in the PR.

## Contents

- [README skeleton](#readme-skeleton) — the exact section order
- [Header block](#header-block) — logo, title, tagline, badges, rule
- [Badge set](#badge-set) — which shields, in which order
- [Tone of voice](#tone-of-voice) — precise, specific, honest
- [SPDX headers](#spdx-headers) — per file type
- [Licensing](#licensing) — dual Apache-2.0 OR MIT
- [Prose conventions](#prose-conventions) — wrapping, tables, code

---

## README skeleton

Every suite README is built from this section order. Sections
that do not apply to a given repo are dropped, never reordered.

1. **Header block** — SPDX comment, centered logo, `<h1>` title,
   one-line centered tagline, badge row, horizontal rule.
2. **Contents** — a `## Contents` table of contents with a short
   dashed annotation after each link (`- [Quick start](#quick-start) — one command`).
   Group links under bold sub-headings (**Getting started**,
   **The suite**, **Operational**) when the list is long.
3. **Quick start** — the shortest path from `git clone` to a
   running container. One fenced block, copy-pasteable.
4. **The suite** — the table of `<language>dev` repos and what
   each one adds on top of the `langdev` core.
5. **Why this approach?** — the design rationale. Numbered
   architectural choices, each with the trade-off it buys. This
   is the section that earns the reader's trust; it is not
   marketing, it is engineering justification with specifics.
6. **Security model** — the container threat model and the exact
   controls (non-root, `cap_drop`, read-only rootfs,
   `no-new-privileges`, pinned + checksummed inputs). Link
   `SECURITY.md` for the reporting process.
7. **Portability** — engines, architectures, host assumptions.
8. **When not to use this** — honest limitations. Every suite
   README carries one. A README with no limitations section is
   incomplete.
9. **Development** — `make` targets, lint/scan/sbom, CI.
10. **Documentation** — links to the community docs and any
    deeper references.
11. **License** — the dual-license stanza (see [Licensing](#licensing)).

---

## Header block

Copy this shape verbatim; substitute the repo name, logo, and
tagline.

```markdown
<!-- SPDX-License-Identifier: Apache-2.0 OR MIT -->

<p align="center">
  <img src="https://cloudcdn.pro/langdev/v1/logos/langdev.svg" alt="langdev logo" width="128" />
</p>

<h1 align="center">langdev</h1>

<p align="center">
  One-line tagline. What it is, for whom, in a single sentence —
  no adjectives that a benchmark or a config line could not back up.
</p>

<p align="center">
  <!-- badge row — see Badge set below -->
</p>

---
```

Rules:

- The tagline is **one sentence**, present tense, concrete. State
  what the thing *is*, not how great it is. "Portable, disposable
  per-language development containers that build with both Docker
  and Podman" — not "the best dev environment ever".
- The title is the bare repo name, lowercase, in an `<h1
  align="center">`. No tagline in the title.
- A single `---` horizontal rule closes the header and separates
  it from `## Contents`.

---

## Badge set

`for-the-badge` style, on one centered row, in this order. Omit a
badge only when it genuinely does not apply to the repo (say so
in the PR); never reorder the ones that remain.

| # | Badge | Source | Applies to |
|---|---|---|---|
| 1 | **Build** — CI status | `img.shields.io/github/actions/workflow/status/sebastienrousseau/<repo>/ci.yml` | every repo with a `ci.yml` |
| 2 | **License** — `Apache-2.0 OR MIT` | `img.shields.io/badge/license-Apache--2.0%20OR%20MIT-blue` | every repo |
| 3 | **OpenSSF Scorecard** | `img.shields.io/ossf-scorecard/github.com/sebastienrousseau/<repo>` | any repo enrolled in Scorecard |
| 4 | **Container engines** — Docker + Podman | `img.shields.io/badge/engines-docker%20%7C%20podman-1d63ed` | every image repo |
| 5 | **Architectures** — `amd64 · arm64` | `img.shields.io/badge/arch-amd64%20%C2%B7%20arm64-555` | every multi-arch image repo |

Every badge uses `?style=for-the-badge`. Add `&logo=…` where a
recognisable logo exists (`github`, `docker`, `openssf`). Each
badge is a link to the thing it reports (the CI runs, the license
file, the Scorecard viewer).

Example row:

```html
<p align="center">
  <a href="https://github.com/sebastienrousseau/langdev/actions"><img src="https://img.shields.io/github/actions/workflow/status/sebastienrousseau/langdev/ci.yml?style=for-the-badge&logo=github" alt="Build" /></a>
  <a href="#license"><img src="https://img.shields.io/badge/license-Apache--2.0%20OR%20MIT-blue?style=for-the-badge" alt="License: Apache-2.0 OR MIT" /></a>
  <a href="https://scorecard.dev/viewer/?uri=github.com/sebastienrousseau/langdev"><img src="https://img.shields.io/ossf-scorecard/github.com/sebastienrousseau/langdev?style=for-the-badge&label=OpenSSF%20Scorecard&logo=openssf" alt="OpenSSF Scorecard" /></a>
  <a href="#portability"><img src="https://img.shields.io/badge/engines-docker%20%7C%20podman-1d63ed?style=for-the-badge&logo=docker" alt="Engines: Docker or Podman" /></a>
  <a href="#portability"><img src="https://img.shields.io/badge/arch-amd64%20%C2%B7%20arm64-555?style=for-the-badge" alt="Architectures: amd64, arm64" /></a>
</p>
```

---

## Tone of voice

The suite's voice is **precise, technical, and honest**. Write
for an experienced engineer who will call a bluff.

- **Specific over general.** "Non-root `dev` (UID/GID 1000), all
  capabilities dropped, read-only rootfs" beats "hardened and
  secure". Name the control, the number, the flag.
- **Claims are falsifiable.** If a sentence makes a claim, the
  reader must be able to check it — a command, a config line, a
  file path. Do not write a claim you cannot point at.
- **No marketing.** No "blazing fast", "enterprise-grade",
  "seamless", "effortless", "revolutionary". Delete adjectives
  that carry no information. If it is fast, give the number; if it
  is small, give the megabytes.
- **Honest limitations.** Every README states where the tool is
  the wrong choice. This is a feature of the voice, not an
  apology. "When not to use this" is a required section.
- **Explain the why.** The "Why this approach?" section justifies
  each design choice by the trade-off it buys, so a future
  contributor understands the reasoning before proposing the
  opposite.
- **Present tense, active voice, imperative for instructions.**
  "The entrypoint attaches to a tmux session" — not "will
  attempt to attach".
- **British spelling** in prose (`behaviour`, `serialise`,
  `optimise`), to match the rest of the suite. Code, flags, and
  quoted tool output keep their upstream spelling.

---

## SPDX headers

Every file in the suite carries an SPDX identifier on (or near)
the first line. The suite is dual-licensed, so the identifier is
always `Apache-2.0 OR MIT`.

| File type | Header |
|---|---|
| Markdown | `<!-- SPDX-License-Identifier: Apache-2.0 OR MIT -->` as the first line, blank line after |
| Shell / Makefile / YAML / Dockerfile | `# SPDX-License-Identifier: Apache-2.0 OR MIT` in the top comment block (after a `#!` shebang or `# syntax=` directive, if present) |
| Containerfile | `# SPDX-License-Identifier: Apache-2.0 OR MIT` after the `# syntax=` line |

The full texts live in [`LICENSE-APACHE`](LICENSE-APACHE) and
[`LICENSE-MIT`](LICENSE-MIT). Do not add a bare `LICENSE` file to
a suite repo — the dual pair is the canonical form.

---

## Licensing

Every suite repo is licensed under **either** Apache License 2.0
**or** the MIT License, at the user's option
(`SPDX-License-Identifier: Apache-2.0 OR MIT`). The README's
`## License` section reads:

```markdown
## License

Licensed under either of

- Apache License, Version 2.0 ([`LICENSE-APACHE`](LICENSE-APACHE))
- MIT license ([`LICENSE-MIT`](LICENSE-MIT))

at your option.

Unless you explicitly state otherwise, any contribution
intentionally submitted for inclusion in the work by you, as
defined in the Apache-2.0 license, shall be dual licensed as
above, without any additional terms or conditions.
```

---

## Prose conventions

- **Wrap prose at ~72 columns.** Long URLs and table rows may
  overrun; sentences should not.
- **Tables for comparisons and inventories.** A three-column
  table beats three paragraphs when the data is parallel.
- **Fenced code blocks are copy-pasteable.** Tag the language
  (` ```sh `, ` ```yaml `, ` ```dockerfile `). A shell block a
  reader is meant to run contains only runnable lines and `#`
  comments, no prose.
- **Link relatively within a repo** (`[SECURITY.md](SECURITY.md)`),
  absolutely across repos.
- **ASCII/UTF-8 only.** No smart quotes in code, no emoji in
  headings or body text.
