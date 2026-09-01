#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/ai-pack.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/ai-pack.sh"

# make_project — a workspace with a normal file, an empty file (skipped: size 0)
# and an oversized file (skipped: >= --max-size). git ls-files is stubbed to
# enumerate them. ai-pack reads relative to $PWD, so tests cd here first.
make_project() {
  PROJ="$SANDBOX/proj"
  mkdir -p "$PROJ"
  printf 'fn main() {}\n' > "$PROJ/a.rs"
  : > "$PROJ/empty.txt"
  printf '%0.sX' {1..120} > "$PROJ/big.txt"
  export STUB_GIT_LSFILES=$'a.rs\nempty.txt\nbig.txt\nmissing.txt'
  cd "$PROJ"
}

@test "ai-pack: runs in test seam with defaults" {
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"AI_PACK_RAN format=xml output=stdout"* ]]
}

@test "ai-pack: seam honours custom format and output" {
  run bash "$REPO_ROOT/$SCRIPT" --format markdown --output context.md
  [ "$status" -eq 0 ]
  [[ "$output" == *"AI_PACK_RAN format=markdown output=context.md"* ]]
}

@test "ai-pack: -h/--help prints usage" {
  run bash "$REPO_ROOT/$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: ai-pack"* ]]
}

@test "ai-pack: xml to stdout respects size limits and escapes" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --max-size 50
  [ "$status" -eq 0 ]
  [[ "$output" == *"<workspace>"* ]]
  [[ "$output" == *'<file path="a.rs">'* ]]
  [[ "$output" == *"fn main"* ]]
  [[ "$output" == *"</workspace>"* ]]
  # empty + oversized + missing files are excluded
  ! [[ "$output" == *"empty.txt"* ]]
  ! [[ "$output" == *"big.txt"* ]]
}

@test "ai-pack: markdown to stdout" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" -f markdown -m 50
  [ "$status" -eq 0 ]
  [[ "$output" == *"# Workspace Code Context"* ]]
  [[ "$output" == *'## File: `a.rs`'* ]]
  [[ "$output" == *"fn main"* ]]
}

@test "ai-pack: xml to an output file" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" -o out.xml -m 50
  [ "$status" -eq 0 ]
  [[ "$output" == *"Packed workspace context into out.xml"* ]]
  [ -f "$PROJ/out.xml" ]
  grep -q "<workspace>" "$PROJ/out.xml"
}

@test "ai-pack: markdown to an output file" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" -f markdown -o out.md -m 50
  [ "$status" -eq 0 ]
  [[ "$output" == *"Packed workspace context into out.md"* ]]
  grep -q "Workspace Code Context" "$PROJ/out.md"
}

@test "ai-pack: stops option parsing at first positional (path) arg" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" -m 50 somepath
  [ "$status" -eq 0 ]
  [[ "$output" == *"<workspace>"* ]]
}
