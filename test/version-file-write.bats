#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run cfenv-version-file-write
  assert_failure "Usage: cfenv version-file-write <file> <version>"
  run cfenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".ruby-version" ]
  run cfenv-version-file-write ".ruby-version" "1.8.7"
  assert_failure "cfenv: version \`1.8.7' not installed"
  assert [ ! -e ".ruby-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${CFENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run cfenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
