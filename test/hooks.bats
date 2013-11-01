#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run cfenv-hooks
  assert_failure "Usage: cfenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${CFENV_TEST_DIR}/cfenv.d"
  path2="${CFENV_TEST_DIR}/etc/cfenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  CFENV_HOOK_PATH="$path1:$path2" run cfenv-hooks exec
  assert_success
  assert_output <<OUT
${CFENV_TEST_DIR}/cfenv.d/exec/ahoy.bash
${CFENV_TEST_DIR}/cfenv.d/exec/hello.bash
${CFENV_TEST_DIR}/etc/cfenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${CFENV_TEST_DIR}/my hooks/cfenv.d"
  path2="${CFENV_TEST_DIR}/etc/cfenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  CFENV_HOOK_PATH="$path1:$path2" run cfenv-hooks exec
  assert_success
  assert_output <<OUT
${CFENV_TEST_DIR}/my hooks/cfenv.d/exec/hello.bash
${CFENV_TEST_DIR}/etc/cfenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${CFENV_TEST_DIR}/cfenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  CFENV_HOOK_PATH="${HOME}/../cfenv.d" run cfenv-hooks exec
  assert_success "${CFENV_TEST_DIR}/cfenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${CFENV_TEST_DIR}/cfenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  CFENV_HOOK_PATH="$path" run cfenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
