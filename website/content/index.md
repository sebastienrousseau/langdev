---
layout: index
title: "langdev — Portable, Disposable AI Developer Container Foundation"
description: "The core foundation of the multi-language suite: 4-pane TMUX IDE, JSON-RPC 2.0 stdio MCP agent server, git worktree pairing, mobile WebTTY, and dotfiles bootstrap."
eyebrow: "Core Foundation"
author: "Sebastien Rousseau"
name: "langdev"
headline: "Portable, Disposable AI Developer Container Foundation"
lead: "The core foundation of the multi-language suite: 4-pane TMUX IDE, JSON-RPC 2.0 stdio MCP agent server, git worktree pairing, mobile WebTTY, and dotfiles bootstrap."
permalink: "/"
language: "en-GB"
date: "2026-08-29"
---

<section id="overview" class="section">
  <div class="container text-center">
    <h2 class="section-title">Engineered for Autonomous AI Agents & Developers</h2>
    <p class="section-desc">A unified container runtime that eliminates context friction between human developers and terminal AI coding agents.</p>
    <div class="grid-2x2">
      <div class="card">
        <h3>4-Pane TMUX IDE (Prefix + i)</h3>
        <p>Instant IDE split layout with File Tree Explorer, Neovim (Treesitter + LSP), bash terminal, and AI Agent pane.</p>
      </div>
      <div class="card">
        <h3>Parallel AI Task Worktrees (muxtree)</h3>
        <p>Automate Git worktrees paired with separate TMUX sessions for concurrent multi-agent and human feature branches.</p>
      </div>
      <div class="card">
        <h3>Model Context Protocol (MCP)</h3>
        <p>Stdio JSON-RPC 2.0 interface exposing file search, bash execution, and diagnostics to Claude Code, Cursor, and Antigravity.</p>
      </div>
      <div class="card">
        <h3>Universal Dotfiles Bootstrap</h3>
        <p>Zero-configuration dotfiles onboarding from any public or private GitHub repository via chezmoi.</p>
      </div>
    </div>
  </div>
</section>

<section id="quickstart" class="section">
  <div class="container narrow">
    <h2 class="section-title text-center">Quick Start in 30 Seconds</h2>
    <p class="section-desc text-center">Disposable developer environment running anywhere Docker or Podman runs.</p>
    <pre><code># 1. Clone the repository
git clone https://github.com/sebastienrousseau/langdev.git
cd langdev

# 2. Build and launch 4-pane TMUX IDE
make up

# 3. Mobile WebTTY (port 7681) &amp; Mosh roaming
make web
make mosh</code></pre>
  </div>
</section>

<section id="features" class="section">
  <div class="container text-center">
    <h2 class="section-title">Core Developer Capabilities</h2>
    <p class="section-desc">Full terminal-first development experience equipped with modern CLI productivity tools.</p>
    <div class="grid-2x2">
      <div class="card">
        <h3>High-Speed Context Packer (ai-pack)</h3>
        <p>Format entire repository codebases into token-efficient XML or Markdown prompt contexts with zero external dependencies.</p>
      </div>
      <div class="card">
        <h3>OSC 52 Universal Clipboard</h3>
        <p>Copy text from remote Neovim or TMUX sessions directly to your local system clipboard over SSH, WebTTY, or Mosh.</p>
      </div>
      <div class="card">
        <h3>Pre-Configured Modern CLI Suite</h3>
        <p>Equipped with ripgrep, fd, bat, eza, fzf, jq, curl, git, and zsh with autosuggestions and syntax highlighting.</p>
      </div>
      <div class="card">
        <h3>Deterministic Reproducibility</h3>
        <p>Pinned tool versions, immutable root filesystem, and hermetic container builds verified by CI test suites.</p>
      </div>
    </div>
  </div>
</section>

<section id="ai-ide" class="section">
  <div class="container text-center">
    <h2 class="section-title">AI Coding Agent Architecture</h2>
    <p class="section-desc">Designed from first principles to empower local coding agents with standard protocols.</p>
    <div class="grid-2x2">
      <div class="card">
        <h3>Model Context Protocol (MCP) Server</h3>
        <p>Runs a native JSON-RPC 2.0 stdio server providing tools for file reading, file search, shell execution, and diagnostics.</p>
      </div>
      <div class="card">
        <h3>Isolated Git Worktree Workflows</h3>
        <p>Spawn ephemeral worktrees for AI tasks without dirtying your main working tree or breaking active development.</p>
      </div>
      <div class="card">
        <h3>Sub-500ms Cold Start Startup</h3>
        <p>Optimized image layers and pre-compiled configurations ensure instantaneous container boot and shell readiness.</p>
      </div>
      <div class="card">
        <h3>Zero-Trust Capability Drop</h3>
        <p>Runs as unprivileged user (UID 1000) with all root capabilities dropped (<code>cap_drop: [ALL]</code>) and read-only rootfs.</p>
      </div>
    </div>
  </div>
</section>

<section id="suite" class="section">
  <div class="container">
    <h2 class="section-title text-center">Unified Multi-Language Suite</h2>
    <p class="section-desc text-center">Every container shares an identical security baseline, TMUX shortcuts, and MCP interfaces.</p>
    <div class="table-responsive">
      <table>
        <thead>
          <tr>
            <th scope="col">Container</th>
            <th scope="col">Language Stack</th>
            <th scope="col">Built-in Tooling</th>
            <th scope="col">Version</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>langdev</strong></td>
            <td>Core Foundation</td>
            <td>TMUX IDE, MCP server, ai-pack, WebTTY, OSC 52</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>pythondev</strong></td>
            <td>Python 3.12+</td>
            <td>uv, ruff, mypy, pytest, debugpy, Pyright</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>rustdev</strong></td>
            <td>Rust 1.85+</td>
            <td>rustup, rust-analyzer, clippy, cargo-audit, sccache</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>godev</strong></td>
            <td>Go 1.24+</td>
            <td>gopls, golangci-lint, delve, Go toolchain</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>javadev</strong></td>
            <td>Java 21+</td>
            <td>OpenJDK 21, Maven, Gradle, JDTLS</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>kotlindev</strong></td>
            <td>Kotlin 2.1+</td>
            <td>kotlinc, OpenJDK 21, Gradle, Maven, KLS</td>
            <td>v0.0.4</td>
          </tr>
          <tr>
            <td><strong>swiftdev</strong></td>
            <td>Swift 6.0+</td>
            <td>Swift toolchain, SourceKit-LSP, swift-format</td>
            <td>v0.0.4</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</section>

<section id="security" class="section">
  <div class="container text-center">
    <h2 class="section-title">Zero-Trust Hardened Security</h2>
    <p class="section-desc">Strict security guarantees verified in CI and container runtime.</p>
    <div class="grid-2x2">
      <div class="card">
        <h3>Unprivileged Non-Root</h3>
        <p>Runs as unprivileged dev user (UID/GID 1000). Drops all Linux capabilities (<code>cap_drop: [ALL]</code>) with <code>no-new-privileges:true</code>.</p>
      </div>
      <div class="card">
        <h3>Read-Only Root Filesystem</h3>
        <p>Immutable rootfs prevents container modification or persistent malware. Writable state is restricted to explicit tmpfs mounts.</p>
      </div>
      <div class="card">
        <h3>Supply Chain Integrity</h3>
        <p>Base images pinned to cryptographic SHA256 digests. Zero unpinned curl-to-sh scripts. Automated CycloneDX SBOM generation.</p>
      </div>
      <div class="card">
        <h3>Hermetic CI &amp; SAST</h3>
        <p>100% unit tested with Bats, ShellCheck linting, Hadolint OCI auditing, and Trivy CVE vulnerability scans.</p>
      </div>
    </div>
  </div>
</section>

<section id="faq" class="section">
  <div class="container narrow">
    <h2 class="section-title text-center">Frequently Asked Questions</h2>
    <div class="faq-stack">
      <div class="card">
        <h3>How fast does the container start?</h3>
        <p>Under 500 milliseconds cold start. All dependencies and dotfile templates are pre-baked into the container image.</p>
      </div>
      <div class="card">
        <h3>Does it support custom dotfiles?</h3>
        <p>Yes. Set <code>DOTFILES_REPO</code> in your <code>.env</code> file, and the container automatically applies your configuration on boot via chezmoi.</p>
      </div>
      <div class="card">
        <h3>Can I run multiple language containers side by side?</h3>
        <p>Yes. All containers in the suite use non-conflicting port mappings and shared worktree patterns for simultaneous multi-language development.</p>
      </div>
    </div>
  </div>
</section>
