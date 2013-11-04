#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.ruby-version" ]
  run cfenv-local
  assert_failure "cfenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .ruby-version
  run cfenv-local
  assert_success "1.2.3"
}

@test "supports legacy .cfenv-version file" {
  echo "1.2.3" > .cfenv-version
  run cfenv-local
  assert_success "1.2.3"
}

@test "local .ruby-version has precedence over .cfenv-version" {
  echo "1.8" > .cfenv-version
  echo "2.0" > .ruby-version
  run cfenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .ruby-version
  mkdir -p "subdir" && cd "subdir"
  run cfenv-local
  assert_failure
}

@test "ignores CFENV_DIR" {
  echo "1.2.3" > .ruby-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.ruby-version"
  CFENV_DIR="$HOME" run cfenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${CFENV_ROOT}/versions/1.2.3"
  run cfenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .ruby-version
  mkdir -p "${CFENV_ROOT}/versions/1.2.3"
  run cfenv-local
  assert_success "1.0-pre"
  run cfenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "renames .cfenv-version to .ruby-version" {
  echo "1.8.7" > .cfenv-version
  mkdir -p "${CFENV_ROOT}/versions/1.9.3"
  run cfenv-local
  assert_success "1.8.7"
  run cfenv-local "1.9.3"
  assert_success
  assert_output <<OUT
cfenv: removed existing \`.cfenv-version' file and migrated
       local version specification to \`.ruby-version' file
OUT
  assert [ ! -e .cfenv-version ]
  assert [ "$(cat .ruby-version)" = "1.9.3" ]
}

@test "doesn't rename .cfenv-version if changing the version failed" {
  echo "1.8.7" > .cfenv-version
  assert [ ! -e "${CFENV_ROOT}/versions/1.9.3" ]
  run cfenv-local "1.9.3"
  assert_failure "cfenv: version \`1.9.3' not installed"
  assert [ ! -e .ruby-version ]
  assert [ "$(cat .cfenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .ruby-version
  run cfenv-local --unset
  assert_success ""
  assert [ ! -e .cfenv-version ]
}

@test "unsets alternate version file" {
  touch .cfenv-version
  run cfenv-local --unset
  assert_success ""
  assert [ ! -e .cfenv-version ]
}
