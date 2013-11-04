#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${CFENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "1.8" "ruby"
  create_executable "1.8" "rake"
  create_executable "2.0" "ruby"
  create_executable "2.0" "rspec"

  run cfenv-whence ruby
  assert_success
  assert_output <<OUT
1.8
2.0
OUT

  run cfenv-whence rake
  assert_success "1.8"

  run cfenv-whence rspec
  assert_success "2.0"
}
