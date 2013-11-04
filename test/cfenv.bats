#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run cfenv
  assert_success
  assert [ "${lines[0]}" = "cfenv 0.4.0" ]
}

@test "invalid command" {
  run cfenv does-not-exist
  assert_failure
  assert_output "cfenv: no such command \`does-not-exist'"
}

@test "default CFENV_ROOT" {
  CFENV_ROOT="" HOME=/home/mislav run cfenv root
  assert_success
  assert_output "/home/mislav/.cfenv"
}

@test "inherited CFENV_ROOT" {
  CFENV_ROOT=/opt/cfenv run cfenv root
  assert_success
  assert_output "/opt/cfenv"
}

@test "default CFENV_DIR" {
  run cfenv echo CFENV_DIR
  assert_output "$(pwd)"
}

@test "inherited CFENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  CFENV_DIR="$dir" run cfenv echo CFENV_DIR
  assert_output "$dir"
}

@test "invalid CFENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  CFENV_DIR="$dir" run cfenv echo CFENV_DIR
  assert_failure
  assert_output "cfenv: cannot change working directory to \`$dir'"
}
