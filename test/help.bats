#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run cfenv-help
  assert_success
  assert_line "Usage: cfenv <command> [<args>]"
  assert_line "Some useful cfenv commands are:"
}

@test "invalid command" {
  run cfenv-help hello
  assert_failure "cfenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  cat > "${CFENV_TEST_DIR}/bin/cfenv-hello" <<SH
#!shebang
# Usage: cfenv hello <world>
# Summary: Says "hello" to you, from cfenv
# This command is useful for saying hello.
echo hello
SH

  run cfenv-help hello
  assert_success
  assert_output <<SH
Usage: cfenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  cat > "${CFENV_TEST_DIR}/bin/cfenv-hello" <<SH
#!shebang
# Usage: cfenv hello <world>
# Summary: Says "hello" to you, from cfenv
echo hello
SH

  run cfenv-help hello
  assert_success
  assert_output <<SH
Usage: cfenv hello <world>

Says "hello" to you, from cfenv
SH
}

@test "extracts only usage" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  cat > "${CFENV_TEST_DIR}/bin/cfenv-hello" <<SH
#!shebang
# Usage: cfenv hello <world>
# Summary: Says "hello" to you, from cfenv
# This extended help won't be shown.
echo hello
SH

  run cfenv-help --usage hello
  assert_success "Usage: cfenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  cat > "${CFENV_TEST_DIR}/bin/cfenv-hello" <<SH
#!shebang
# Usage: cfenv hello <world>
#        cfenv hi [everybody]
#        cfenv hola --translate
# Summary: Says "hello" to you, from cfenv
# Help text.
echo hello
SH

  run cfenv-help hello
  assert_success
  assert_output <<SH
Usage: cfenv hello <world>
       cfenv hi [everybody]
       cfenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  cat > "${CFENV_TEST_DIR}/bin/cfenv-hello" <<SH
#!shebang
# Usage: cfenv hello <world>
# Summary: Says "hello" to you, from cfenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run cfenv-help hello
  assert_success
  assert_output <<SH
Usage: cfenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
