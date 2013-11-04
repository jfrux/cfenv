#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${CFENV_ROOT}/version" ]
  run cfenv-version-origin
  assert_success "${CFENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$CFENV_ROOT"
  touch "${CFENV_ROOT}/version"
  run cfenv-version-origin
  assert_success "${CFENV_ROOT}/version"
}

@test "detects CFENV_VERSION" {
  CFENV_VERSION=1 run cfenv-version-origin
  assert_success "CFENV_VERSION environment variable"
}

@test "detects local file" {
  touch .ruby-version
  run cfenv-version-origin
  assert_success "${PWD}/.ruby-version"
}

@test "detects alternate version file" {
  touch .cfenv-version
  run cfenv-version-origin
  assert_success "${PWD}/.cfenv-version"
}
