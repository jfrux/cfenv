#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  mkdir -p "${CFENV_ROOT}/versions/1.2.3"
  run cfenv-prefix
  assert_success "${CFENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  CFENV_VERSION="1.2.3" run cfenv-prefix
  assert_failure "cfenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  touch "${CFENV_TEST_DIR}/bin/ruby"
  chmod +x "${CFENV_TEST_DIR}/bin/ruby"
  CFENV_VERSION="system" run cfenv-prefix
  assert_success "$CFENV_TEST_DIR"
}

@test "prefix for invalid system" {
  USRBIN_ALT="${CFENV_TEST_DIR}/usr-bin-alt"
  mkdir -p "$USRBIN_ALT"
  for util in head readlink greadlink; do
    if [ -x "/usr/bin/$util" ]; then
      ln -s "/usr/bin/$util" "${USRBIN_ALT}/$util"
    fi
  done
  PATH_WITHOUT_RUBY="${PATH/\/usr\/bin:/$USRBIN_ALT:}"

  PATH="$PATH_WITHOUT_RUBY" run cfenv-prefix system
  assert_failure "cfenv: system version not found in PATH"
}
