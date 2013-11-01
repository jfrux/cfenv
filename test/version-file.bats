#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${CFENV_ROOT}/version" ]
  assert [ ! -e ".ruby-version" ]
  run cfenv-version-file
  assert_success "${CFENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${CFENV_ROOT}/global"
  run cfenv-version-file
  assert_success "${CFENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${CFENV_ROOT}/default"
  run cfenv-version-file
  assert_success "${CFENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${CFENV_ROOT}/version"
  create_file "${CFENV_ROOT}/global"
  create_file "${CFENV_ROOT}/default"
  run cfenv-version-file
  assert_success "${CFENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".ruby-version"
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/.ruby-version"
}

@test "legacy file in current directory" {
  create_file ".cfenv-version"
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/.cfenv-version"
}

@test ".ruby-version has precedence over legacy file" {
  create_file ".ruby-version"
  create_file ".cfenv-version"
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/.ruby-version"
}

@test "in parent directory" {
  create_file ".ruby-version"
  mkdir -p project
  cd project
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/.ruby-version"
}

@test "topmost file has precedence" {
  create_file ".ruby-version"
  create_file "project/.ruby-version"
  cd project
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/project/.ruby-version"
}

@test "legacy file has precedence if higher" {
  create_file ".ruby-version"
  create_file "project/.cfenv-version"
  cd project
  run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/project/.cfenv-version"
}

@test "CFENV_DIR has precedence over PWD" {
  create_file "widget/.ruby-version"
  create_file "project/.ruby-version"
  cd project
  CFENV_DIR="${CFENV_TEST_DIR}/widget" run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/widget/.ruby-version"
}

@test "PWD is searched if CFENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.ruby-version"
  cd project
  CFENV_DIR="${CFENV_TEST_DIR}/widget/blank" run cfenv-version-file
  assert_success "${CFENV_TEST_DIR}/project/.ruby-version"
}
