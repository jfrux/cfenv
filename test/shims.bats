#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run cfenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/ruby"
  touch "${CFENV_ROOT}/shims/irb"
  run cfenv-shims
  assert_success
  assert_line "${CFENV_ROOT}/shims/ruby"
  assert_line "${CFENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/ruby"
  touch "${CFENV_ROOT}/shims/irb"
  run cfenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "ruby"
}
