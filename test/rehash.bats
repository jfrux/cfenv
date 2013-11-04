#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${CFENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${CFENV_ROOT}/shims" ]
  run cfenv-rehash
  assert_success ""
  assert [ -d "${CFENV_ROOT}/shims" ]
  rmdir "${CFENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${CFENV_ROOT}/shims"
  chmod -w "${CFENV_ROOT}/shims"
  run cfenv-rehash
  assert_failure "cfenv: cannot rehash: ${CFENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/.cfenv-shim"
  run cfenv-rehash
  assert_failure "cfenv: cannot rehash: ${CFENV_ROOT}/shims/.cfenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "ruby"
  create_executable "1.8" "rake"
  create_executable "2.0" "ruby"
  create_executable "2.0" "rspec"

  assert [ ! -e "${CFENV_ROOT}/shims/ruby" ]
  assert [ ! -e "${CFENV_ROOT}/shims/rake" ]
  assert [ ! -e "${CFENV_ROOT}/shims/rspec" ]

  run cfenv-rehash
  assert_success ""

  run ls "${CFENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
ruby
OUT
}

@test "removes stale shims" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/oldshim1"
  chmod +x "${CFENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "rake"
  create_executable "2.0" "ruby"

  run cfenv-rehash
  assert_success ""

  assert [ ! -e "${CFENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "ruby"
  create_executable "dirname2 preview1" "rspec"

  assert [ ! -e "${CFENV_ROOT}/shims/ruby" ]
  assert [ ! -e "${CFENV_ROOT}/shims/rspec" ]

  run cfenv-rehash
  assert_success ""

  run ls "${CFENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rspec
ruby
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${CFENV_TEST_DIR}/cfenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  CFENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run cfenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "ruby"
  CFENV_SHELL=bash run cfenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${CFENV_ROOT}/shims/ruby" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "ruby"
  CFENV_SHELL=fish run cfenv-sh-rehash
  assert_success ""
  assert [ -x "${CFENV_ROOT}/shims/ruby" ]
}
