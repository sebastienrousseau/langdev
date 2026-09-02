#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/tmux-ide.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/tmux-ide.sh"
run_ide() { run bash "$REPO_ROOT/$SCRIPT" "$@"; }

# --- Arg parsing / seam (LANGDEV_TEST=1) -------------------------------------

@test "tmux-ide: --help prints usage and exits 0" {
  run_ide --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: tmux-ide"* ]]
  [[ "$output" == *"Prefix + i"* ]]
}

@test "tmux-ide: unknown arg exits 2" {
  run_ide --bogus-arg
  [ "$status" -eq 2 ]
  [[ "$output" == *"error: unknown argument"* ]]
}

@test "tmux-ide: seam reports default ide layout" {
  run_ide
  [ "$status" -eq 0 ]
  [[ "$output" == *"TMUX_IDE_RAN layout=ide"* ]]
}

@test "tmux-ide: seam honours custom layout/session/workdir/auto" {
  run_ide --layout minimalist --session custom-ses --workdir "$SANDBOX" --auto
  [ "$status" -eq 0 ]
  [[ "$output" == *"TMUX_IDE_RAN layout=minimalist session=custom-ses"* ]]
  [[ "$output" == *"workdir=$SANDBOX"* ]]
  [[ "$output" == *"auto=1"* ]]
}

# --- Real-body coverage (LANGDEV_TEST unset) ---------------------------------

@test "tmux-ide: aborts when tmux is not installed" {
  unset LANGDEV_TEST
  hermetic_path
  run_ide
  [ "$status" -eq 1 ]
  [[ "$output" == *"tmux is required"* ]]
}

@test "tmux-ide: --launch attaches to an existing session" {
  unset LANGDEV_TEST
  export STUB_TMUX_HAS_SESSION=0
  hermetic_path tmux
  run_ide --launch
  [ "$status" -eq 0 ]
  stublog_has "tmux attach-session -t langdev"
}

@test "tmux-ide: --launch creates a new session then attaches" {
  unset LANGDEV_TEST
  export STUB_TMUX_HAS_SESSION=1  # no existing session
  hermetic_path tmux nvim
  run_ide --launch
  [ "$status" -eq 0 ]
  stublog_has "tmux new-session -d -s langdev"
  stublog_has "tmux attach-session -t langdev"
  # the recursive layout call ran the ide splits
  stublog_has "tmux split-window"
}

@test "tmux-ide: ide layout with all tools rebuilds existing window" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=2  # >1 -> kill-pane rebuild branch
  hermetic_path tmux yazi nvim claude
  run_ide --workdir "$SANDBOX"
  [ "$status" -eq 0 ]
  stublog_has "tmux kill-pane"
  stublog_has "tmux split-window -h -b -l 20%"
  stublog_has "tmux select-pane"
  stublog_has "tmux send-keys -t langdev:.1 yazi"
  stublog_has "tmux send-keys -t langdev:.2 nvim ."
  stublog_has "tmux send-keys -t langdev:.4 claude"
}

@test "tmux-ide: ide layout falls back to banners without tools" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=1
  hermetic_path tmux
  run_ide
  [ "$status" -eq 0 ]
  ! stublog_has "tmux kill-pane"
  stublog_has "Explorer Pane"
  stublog_has "AI Agent Pane"
}

@test "tmux-ide: ide layout uses langdev-explorer and agy" {
  unset LANGDEV_TEST
  hermetic_path tmux langdev-explorer agy
  run_ide
  [ "$status" -eq 0 ]
  stublog_has "send-keys -t langdev:.1 langdev-explorer"
  stublog_has "send-keys -t langdev:.4 agy"
}

@test "tmux-ide: ide layout uses ollama when only it is present" {
  unset LANGDEV_TEST
  hermetic_path tmux ollama
  run_ide
  [ "$status" -eq 0 ]
  stublog_has "send-keys -t langdev:.4 ollama run llama3.2"
}

@test "tmux-ide: minimalist layout with tools" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=2
  hermetic_path tmux nvim claude
  run_ide --layout minimalist
  [ "$status" -eq 0 ]
  stublog_has "tmux kill-pane"
  stublog_has "tmux split-window -h -l 35%"
  stublog_has "send-keys -t langdev:.1 nvim ."
  stublog_has "send-keys -t langdev:.3 claude"
}

@test "tmux-ide: minimalist layout without tools (single pane)" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=1
  hermetic_path tmux
  run_ide --layout minimalist
  [ "$status" -eq 0 ]
  ! stublog_has "tmux kill-pane"
  stublog_has "tmux split-window -v -l 30%"
}

@test "tmux-ide: focus layout zooms the active pane" {
  unset LANGDEV_TEST
  hermetic_path tmux
  run_ide --layout focus
  [ "$status" -eq 0 ]
  stublog_has "tmux resize-pane -Z"
}

@test "tmux-ide: unknown layout exits 2" {
  unset LANGDEV_TEST
  hermetic_path tmux
  run_ide --layout bogus
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown layout"* ]]
}

@test "tmux-ide: --auto skips formatting when window already split" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=2
  hermetic_path tmux
  run_ide --auto
  [ "$status" -eq 0 ]
  ! stublog_has "tmux split-window"
}

@test "tmux-ide: --auto formats when the window has a single pane" {
  unset LANGDEV_TEST
  export STUB_TMUX_PANES=1
  hermetic_path tmux nvim
  run_ide --auto
  [ "$status" -eq 0 ]
  stublog_has "tmux split-window"
}
