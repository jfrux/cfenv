#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${CFENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${CFENV_ROOT}/versions" ]
  run cfenv-version
  assert_success "system (set by ${CFENV_ROOT}/version)"
}

@test "set by CFENV_VERSION" {
  create_version "1.9.3"
  CFENV_VERSION=1.9.3 run cfenv-version
  assert_success "1.9.3 (set by CFENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".ruby-version" <<<"1.9.3"
  run cfenv-version
  assert_success "1.9.3 (set by ${PWD}/.ruby-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${CFENV_ROOT}/version" <<<"1.9.3"
  run cfenv-version
  assert_success "1.9.3 (set by ${CFENV_ROOT}/version)"
}
