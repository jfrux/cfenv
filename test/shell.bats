#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  CFENV_VERSION="" run cfenv-sh-shell
  assert_failure "cfenv: no shell-specific version configured"
}

@test "shell version" {
  CFENV_SHELL=bash CFENV_VERSION="1.2.3" run cfenv-sh-shell
  assert_success 'echo "$CFENV_VERSION"'
}

@test "shell version (fish)" {
  CFENV_SHELL=fish CFENV_VERSION="1.2.3" run cfenv-sh-shell
  assert_success 'echo "$CFENV_VERSION"'
}

@test "shell unset" {
  CFENV_SHELL=bash run cfenv-sh-shell --unset
  assert_success "unset CFENV_VERSION"
}

@test "shell unset (fish)" {
  CFENV_SHELL=fish run cfenv-sh-shell --unset
  assert_success "set -e CFENV_VERSION"
}

@test "shell change invalid version" {
  run cfenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
cfenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${CFENV_ROOT}/versions/1.2.3"
  CFENV_SHELL=bash run cfenv-sh-shell 1.2.3
  assert_success 'export CFENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${CFENV_ROOT}/versions/1.2.3"
  CFENV_SHELL=fish run cfenv-sh-shell 1.2.3
  assert_success 'setenv CFENV_VERSION "1.2.3"'
}
