#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/muxtree.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/muxtree.sh"
run_mux() { run bash "$REPO_ROOT/$SCRIPT" "$@"; }

# --- Test-seam coverage (LANGDEV_TEST=1, set by common_setup) ----------------

@test "muxtree: --help prints usage and exits 0 (seam)" {
  run_mux --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: muxtree"* ]]
}

@test "muxtree: unknown command exits 2 (seam)" {
  run_mux invalid-cmd
  [ "$status" -eq 2 ]
  [[ "$output" == *"error: unknown command"* ]]
}

@test "muxtree: new records command (seam)" {
  run_mux new feat/ai-agent
  [ "$status" -eq 0 ]
  [[ "$output" == *"MUXTREE_RAN cmd=new args=feat/ai-agent"* ]]
}

@test "muxtree: list/switch/remove/menu record command (seam)" {
  run_mux list
  [[ "$output" == *"MUXTREE_RAN cmd=list"* ]]
  run_mux switch feat/x
  [[ "$output" == *"MUXTREE_RAN cmd=switch args=feat/x"* ]]
  run_mux remove feat/x
  [[ "$output" == *"MUXTREE_RAN cmd=remove args=feat/x"* ]]
  run_mux menu
  [[ "$output" == *"MUXTREE_RAN cmd=menu"* ]]
}

# --- Real-body coverage (LANGDEV_TEST unset) ---------------------------------

@test "muxtree: real help + unknown command paths" {
  unset LANGDEV_TEST
  hermetic_path git tmux
  run_mux help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: muxtree"* ]]

  run_mux bogus-cmd
  [ "$status" -eq 2 ]
  [[ "$output" == *"error: unknown command"* ]]
}

@test "muxtree: new creates worktree with new branch and attaches" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_GIT_SHOWREF_RC=1   # branch does not exist -> add -b
  export STUB_TMUX_HAS_SESSION=1 # session absent -> create it
  hermetic_path git tmux tmux-ide
  run_mux new feat/ai
  [ "$status" -eq 0 ]
  stublog_has "git worktree add -b feat/ai"
  stublog_has "tmux new-session -d -s langdev-feat-ai"
  stublog_has "tmux-ide --session langdev-feat-ai"
  stublog_has "tmux attach-session -t langdev-feat-ai"
}

@test "muxtree: new with existing branch + existing session + inside tmux" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_GIT_SHOWREF_RC=0   # branch exists -> add without -b
  export STUB_TMUX_HAS_SESSION=0 # session already exists -> no new-session
  export TMUX="fake-tmux"        # inside tmux -> switch-client
  hermetic_path git tmux tmux-ide
  run_mux create feat/ai
  [ "$status" -eq 0 ]
  stublog_has "git worktree add $STUB_GIT_TOPLEVEL/.worktrees/feat-ai feat/ai"
  ! stublog_has "tmux new-session"
  stublog_has "tmux switch-client -t langdev-feat-ai"
}

@test "muxtree: new skips creation when worktree dir already exists" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"
  mkdir -p "$STUB_GIT_TOPLEVEL/.worktrees/feat-ai"
  export STUB_TMUX_HAS_SESSION=0
  hermetic_path git tmux
  run_mux new feat/ai
  [ "$status" -eq 0 ]
  ! stublog_has "git worktree add"
}

@test "muxtree: new without branch errors" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  hermetic_path git tmux
  run_mux new
  [ "$status" -eq 1 ]
  [[ "$output" == *"please provide a branch name"* ]]
}

@test "muxtree: new outside a git repo errors" {
  unset LANGDEV_TEST
  export STUB_GIT_NOT_REPO=1
  hermetic_path git tmux
  run_mux new feat/ai
  [ "$status" -eq 1 ]
  [[ "$output" == *"must be run inside a Git repository"* ]]
}

@test "muxtree: list renders worktrees (active + inactive + detached)" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_TMUX_HAS_SESSION=0   # sessions active
  hermetic_path git tmux
  run_mux list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Active Git Worktrees"* ]]
  [[ "$output" == *"main"* ]]
  [[ "$output" == *"feat/x"* ]]
  [[ "$output" == *"detached"* ]]
  [[ "$output" == *"active"* ]]

  export STUB_TMUX_HAS_SESSION=1   # sessions inactive
  run_mux ls
  [[ "$output" == *"inactive"* ]]
}

@test "muxtree: switch attaches/switches to an existing session" {
  unset LANGDEV_TEST
  export STUB_TMUX_HAS_SESSION=0
  hermetic_path git tmux
  run_mux switch feat/ai
  [ "$status" -eq 0 ]
  stublog_has "tmux attach-session -t langdev-feat-ai"

  export TMUX="fake-tmux"
  run_mux sw feat/ai
  stublog_has "tmux switch-client -t langdev-feat-ai"
}

@test "muxtree: switch errors on missing branch and missing session" {
  unset LANGDEV_TEST
  hermetic_path git tmux
  run_mux switch
  [ "$status" -eq 1 ]
  [[ "$output" == *"please provide a branch name"* ]]

  export STUB_TMUX_HAS_SESSION=1
  run_mux switch feat/nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "muxtree: remove kills session and removes worktree" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"
  mkdir -p "$STUB_GIT_TOPLEVEL/.worktrees/feat-ai"
  export STUB_TMUX_HAS_SESSION=0
  hermetic_path git tmux
  run_mux remove feat/ai
  [ "$status" -eq 0 ]
  stublog_has "tmux kill-session -t langdev-feat-ai"
  stublog_has "git worktree remove $STUB_GIT_TOPLEVEL/.worktrees/feat-ai --force"
  [[ "$output" == *"Cleaned up worktree"* ]]
}

@test "muxtree: remove without branch errors" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  hermetic_path git tmux
  run_mux rm
  [ "$status" -eq 1 ]
  [[ "$output" == *"please provide a branch name"* ]]
}

@test "muxtree: menu via fzf switches to selection" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_FZF_OUT="feat/x"
  export STUB_TMUX_HAS_SESSION=0
  export TMUX="fake-tmux"
  hermetic_path git tmux fzf
  run_mux menu
  [ "$status" -eq 0 ]
  stublog_has "fzf"
  stublog_has "tmux switch-client -t langdev-feat-x"
}

@test "muxtree: menu via fzf with empty selection does nothing" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_FZF_OUT=""
  hermetic_path git tmux fzf
  run_mux menu
  [ "$status" -eq 0 ]
  ! stublog_has "switch-client"
}

@test "muxtree: menu select loop — switch, cancel, invalid, create" {
  unset LANGDEV_TEST
  export STUB_GIT_TOPLEVEL="$SANDBOX/repo"; mkdir -p "$STUB_GIT_TOPLEVEL"
  export STUB_TMUX_HAS_SESSION=0
  export TMUX="fake-tmux"
  hermetic_path git tmux tmux-ide

  # 1 -> selects "main" -> cmd_switch
  run_mux menu <<< $'1\n'
  [ "$status" -eq 0 ]
  stublog_has "tmux switch-client -t langdev-main"

  # explicit Cancel option
  run_mux menu <<< $'4\n'
  [ "$status" -eq 0 ]

  # out-of-range -> empty selection -> break
  run_mux menu <<< $'9\n'
  [ "$status" -eq 0 ]

  # "Create new task worktree" -> reads branch name -> cmd_new
  export STUB_TMUX_HAS_SESSION=1
  run_mux menu <<< $'3\nfeat/created\n'
  [ "$status" -eq 0 ]
  stublog_has "tmux new-session -d -s langdev-feat-created"
}
