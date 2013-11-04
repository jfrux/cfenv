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
  run cfenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  CFENV_VERSION=system run cfenv-version-name
  assert_success "system"
}

@test "CFENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".ruby-version" <<<"1.8.7"
  run cfenv-version-name
  assert_success "1.8.7"

  CFENV_VERSION=1.9.3 run cfenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${CFENV_ROOT}/version" <<<"1.8.7"
  run cfenv-version-name
  assert_success "1.8.7"

  cat > ".ruby-version" <<<"1.9.3"
  run cfenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  CFENV_VERSION=1.2 run cfenv-version-name
  assert_failure "cfenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".ruby-version" <<<"ruby-1.8.7"
  run cfenv-version-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`ruby-' prefix in version \`ruby-1.8.7'
         (set by ${PWD}/.ruby-version)
1.8.7
OUT
}
