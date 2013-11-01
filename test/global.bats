#!/usr/bin/env bats

load test_helper

@test "default" {
  run cfenv global
  assert_success
  assert_output "system"
}

@test "read CFENV_ROOT/version" {
  mkdir -p "$CFENV_ROOT"
  echo "1.2.3" > "$CFENV_ROOT/version"
  run cfenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set CFENV_ROOT/version" {
  mkdir -p "$CFENV_ROOT/versions/1.2.3"
  run cfenv-global "1.2.3"
  assert_success
  run cfenv global
  assert_success "1.2.3"
}

@test "fail setting invalid CFENV_ROOT/version" {
  mkdir -p "$CFENV_ROOT"
  run cfenv-global "1.2.3"
  assert_failure "cfenv: version \`1.2.3' not installed"
}
