#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${CFENV_ROOT}/shims" ]
  assert [ ! -d "${CFENV_ROOT}/versions" ]
  run cfenv-init -
  assert_success
  assert [ -d "${CFENV_ROOT}/shims" ]
  assert [ -d "${CFENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run cfenv-init -
  assert_success
  assert_line "cfenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run cfenv-init - bash
  assert_success
  assert_line "source '${root}/libexec/../completions/cfenv.bash'"
}

@test "detect parent shell" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  SHELL=/bin/false run cfenv-init -
  assert_success
  assert_line "export CFENV_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run cfenv-init - fish
  assert_success
  assert_line ". '${root}/libexec/../completions/cfenv.fish'"
}

@test "option to skip rehash" {
  run cfenv-init - --no-rehash
  assert_success
  refute_line "cfenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin"
  run cfenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${CFENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin"
  run cfenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${CFENV_ROOT}/shims' \$PATH"
}

@test "doesn't add shims to PATH more than once" {
  export PATH="${CFENV_ROOT}/shims:$PATH"
  run cfenv-init - bash
  assert_success
  refute_line 'export PATH="'${CFENV_ROOT}'/shims:${PATH}"'
}

@test "doesn't add shims to PATH more than once (fish)" {
  export PATH="${CFENV_ROOT}/shims:$PATH"
  run cfenv-init - fish
  assert_success
  refute_line 'setenv PATH "'${CFENV_ROOT}'/shims" $PATH ;'
}
