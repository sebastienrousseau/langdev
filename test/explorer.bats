#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/explorer.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/explorer.sh"

@test "explorer: runs in test seam with status ok" {
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"EXPLORER_RAN status=ok"* ]]
}

@test "explorer: execs yazi when available" {
  unset LANGDEV_TEST
  hermetic_path yazi git clear
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  stublog_has "yazi"
}

@test "explorer: interactive loop with fzf/lazygit/tmux (tree present)" {
  unset LANGDEV_TEST
  export TMUX="fake-tmux"
  export STUB_FZF_OUT="src/main.rs"
  export STUB_GIT_BRANCH="feature/x"
  hermetic_path git tree clear fzf lazygit tmux
  run bash "$REPO_ROOT/$SCRIPT" <<< $'f\ng\nr\ne notes.txt\nbogus\nq'
  [ "$status" -eq 0 ]
  [[ "$output" == *"PROJECT EXPLORER"* ]]
  [[ "$output" == *"feature/x"* ]]
  stublog_has "fzf"
  stublog_has "lazygit"
  stublog_has "tmux send-keys"
  stublog_has "tree"
}

@test "explorer: loop without fzf/lazygit/tmux falls back (find tree, git status)" {
  unset LANGDEV_TEST
  hermetic_path git clear
  run bash "$REPO_ROOT/$SCRIPT" <<< $'f\ng\ne foo.txt\nq'
  [ "$status" -eq 0 ]
  [[ "$output" == *"PROJECT EXPLORER"* ]]
  stublog_has "git status"
  ! stublog_has "tmux send-keys"
}

@test "explorer: EOF on prompt breaks the loop" {
  unset LANGDEV_TEST
  hermetic_path git clear
  run bash "$REPO_ROOT/$SCRIPT" < /dev/null
  [ "$status" -eq 0 ]
  [[ "$output" == *"PROJECT EXPLORER"* ]]
}
