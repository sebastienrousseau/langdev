#!/usr/bin/env bats
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Unit tests for common/doctor.sh
load helpers/common

setup() { common_setup; }

SCRIPT="common/doctor.sh"

@test "doctor: runs diagnostic healthcheck and exits 0 (test seam)" {
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"LANGDEV_DOCTOR_RAN status=ok"* ]]
}

@test "doctor: docker running, mixed host/QA tools, xterm, AI agent" {
  unset LANGDEV_TEST
  export TERM=xterm-256color
  export STUB_DOCKER_INFO_RC=0
  # docker+daemon up; host git present but tmux/ssh absent; shellcheck present
  # (pass) while others absent (info); claude present (AI pass).
  hermetic_path docker git curl shellcheck claude
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docker Engine installed & running"* ]]
  [[ "$output" == *"[OK]"* ]]
  [[ "$output" == *"[WARN]"* ]]
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"AI Agent 'claude' detected"* ]]
  [[ "$output" == *"Diagnostics completed."* ]]
}

@test "doctor: docker binary present but daemon down warns" {
  unset LANGDEV_TEST
  export STUB_DOCKER_INFO_RC=1
  hermetic_path docker
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"daemon is not responding"* ]]
}

@test "doctor: podman fallback when docker absent" {
  unset LANGDEV_TEST
  hermetic_path podman
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Podman installed"* ]]
}

@test "doctor: no engine + unknown terminal reports fail/info" {
  unset LANGDEV_TEST
  export TERM=dumb
  hermetic_path
  run bash "$REPO_ROOT/$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No container engine found"* ]]
  [[ "$output" == *"Terminal (dumb) detected"* ]]
}
