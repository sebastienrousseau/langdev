#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/mcp-server.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/mcp-server.sh"

# make_project — a small workspace the server can cd into and inspect.
make_project() {
  PROJ="$SANDBOX/proj"
  mkdir -p "$PROJ/sub"
  printf 'hello world\n' > "$PROJ/notes.txt"
  printf 'x\n' > "$PROJ/sub/a.txt"
  export LANGDEV_WORKDIR="$PROJ"
}

@test "mcp-server: runs with default args in test seam" {
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"MCP_SERVER_RAN"* ]]
}

@test "mcp-server: accepts tools query in test seam" {
  run bash "$REPO_ROOT/$SCRIPT" --tools
  [ "$status" -eq 0 ]
  [[ "$output" == *"MCP_SERVER_RAN args=--tools"* ]]
}

@test "mcp-server: --tools emits JSON-RPC tool list" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --tools
  [ "$status" -eq 0 ]
  [[ "$output" == *'"name":"list_files"'* ]]
  [[ "$output" == *'"name":"run_command"'* ]]
}

@test "mcp-server: --help prints usage" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Model Context Protocol"* ]]
}

@test "mcp-server: --call list_files returns files" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call list_files .
  [ "$status" -eq 0 ]
  [[ "$output" == *'"result"'* ]]
  [[ "$output" == *"notes.txt"* ]]
}

@test "mcp-server: --call read_file returns content and errors on missing" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call read_file notes.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello world"* ]]

  run bash "$REPO_ROOT/$SCRIPT" --call read_file nope.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"File not found"* ]]
  [[ "$output" == *"-32602"* ]]
}

@test "mcp-server: --call git_status and git_diff" {
  unset LANGDEV_TEST
  make_project
  export STUB_GIT_STATUS="## main...origin/main"
  export STUB_GIT_DIFF="diff --git a/x b/x"
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call git_status
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]

  run bash "$REPO_ROOT/$SCRIPT" --call git_diff
  [ "$status" -eq 0 ]
  [[ "$output" == *"diff --git"* ]]
}

@test "mcp-server: --call run_tests default (no build files)" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call run_tests
  [ "$status" -eq 0 ]
  [[ "$output" == *"No tests configured"* ]]
}

@test "mcp-server: --call run_tests runs make when Makefile has test target" {
  unset LANGDEV_TEST
  make_project
  printf 'test:\n\t@echo ran\n' > "$PROJ/Makefile"
  hermetic_path git make
  run bash "$REPO_ROOT/$SCRIPT" --call run_tests
  [ "$status" -eq 0 ]
  stublog_has "make test"
}

@test "mcp-server: --call run_tests uses cargo/pytest/go per manifest" {
  unset LANGDEV_TEST
  make_project
  printf '[package]\n' > "$PROJ/Cargo.toml"
  hermetic_path git cargo
  run bash "$REPO_ROOT/$SCRIPT" --call run_tests
  [ "$status" -eq 0 ]
  stublog_has "cargo test"
  rm -f "$PROJ/Cargo.toml"

  : > "$STUB_LOG"
  printf '[project]\n' > "$PROJ/pyproject.toml"
  hermetic_path git pytest
  run bash "$REPO_ROOT/$SCRIPT" --call run_tests
  [ "$status" -eq 0 ]
  stublog_has "pytest"
  rm -f "$PROJ/pyproject.toml"

  : > "$STUB_LOG"
  printf 'module x\n' > "$PROJ/go.mod"
  hermetic_path git go
  run bash "$REPO_ROOT/$SCRIPT" --call run_tests
  [ "$status" -eq 0 ]
  stublog_has "go test ./..."
}

@test "mcp-server: --call run_command executes shell" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call run_command "printf hi"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hi"* ]]
}

@test "mcp-server: --call unknown tool returns method-not-found" {
  unset LANGDEV_TEST
  make_project
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" --call frobnicate
  [ "$status" -eq 0 ]
  [[ "$output" == *"-32601"* ]]
  [[ "$output" == *"Method not found"* ]]
}

@test "mcp-server: stdio JSON-RPC loop handles initialize/list/call/unknown" {
  unset LANGDEV_TEST
  make_project
  export STUB_GIT_STATUS="## main"
  hermetic_path git
  run bash "$REPO_ROOT/$SCRIPT" <<< $'{"jsonrpc":"2.0","id":1,"method":"initialize"}\n{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"git_status"}}\n{"jsonrpc":"2.0","id":4,"method":"ping"}'
  [ "$status" -eq 0 ]
  [[ "$output" == *"protocolVersion"* ]]
  [[ "$output" == *'"name":"read_file"'* ]]
  [[ "$output" == *'{"jsonrpc":"2.0","id":1,"result":{}}'* ]]
}
