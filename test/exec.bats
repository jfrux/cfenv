#!/usr/bin/env bats

load test_helper

create_executable() {
  local file="${1?}"
  [[ $file == */* ]] || file="${CFENV_ROOT}/versions/${CFENV_VERSION}/bin/$file"
  shift 1
  mkdir -p "${file%/*}"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^[[:space:]]+//' > "$file"
  chmod +x "$file"
}

# Fake ruby executable that emulates `ruby -S <cmd>' behavior by running the
# first `cmd' found in RUBYPATH/PATH as bash script.
create_ruby_executable() {
  create_executable "${1:-ruby}" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  cmd="\${1#-S}"
  [ -n "\$cmd" ] || cmd="\$2"
  found="\$(PATH="\${RUBYPATH:-\$PATH}" \$(command -v which) \$cmd)"
  # assert that the found executable has ruby for shebang
  if head -1 "\$found" | grep ruby >/dev/null; then
    \$BASH "\$found"
  else
    echo "ruby: no Ruby script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'ruby (cfenv test)'
fi
SH
}

@test "fails with invalid version" {
  export CFENV_VERSION="2.0"
  run cfenv-exec ruby -v
  assert_failure "cfenv: version \`2.0' is not installed"
}

@test "completes with names of executables" {
  export CFENV_VERSION="2.0"
  create_executable "ruby" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  cfenv-rehash
  run cfenv-completions exec
  assert_success
  assert_output <<OUT
rake
ruby
OUT
}

@test "supports hook path with spaces" {
  hook_path="${CFENV_TEST_DIR}/custom stuff/cfenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export CFENV_VERSION=system
  CFENV_HOOK_PATH="$hook_path" run cfenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${CFENV_TEST_DIR}/cfenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export CFENV_VERSION=system
  CFENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run cfenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export CFENV_VERSION="2.0"
  create_executable "ruby" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run cfenv-exec ruby -w "/path to/ruby script.rb" -- extra args
  assert_success
  assert_output <<OUT
${CFENV_ROOT}/versions/2.0/bin/ruby
  -w
  /path to/ruby script.rb
  --
  extra
  args
OUT
}

@test "doesn't mutate PATH" {
  export CFENV_VERSION="2.0"
  create_executable "ruby" <<SH
#!$BASH
echo \$PATH
SH

  run cfenv-exec ruby
  assert_success "$PATH"
}

@test "doesn't set RUBYPATH" {
  export CFENV_VERSION="2.0"
  create_executable "ruby" <<SH
#!$BASH
echo \$RUBYPATH
SH

  RUBYPATH="" run cfenv-exec ruby
  assert_success
  assert_output ""
}

@test "allows subprocesses to select a different CFENV_VERSION" {
  CFENV_VERSION=1.8 create_executable "rake" <<SH
#!$BASH
echo rake 1.8
SH

  export CFENV_VERSION="2.0"
  create_executable "rake" "#!/bin/sh"
  create_executable "ruby" <<SH
#!$BASH
echo ruby 2.0
CFENV_VERSION=1.8 exec rake
SH

  cfenv rehash
  run ruby
  assert_success
  assert_output <<OUT
ruby 2.0
rake 1.8
OUT
}

@test "supports ruby -S <cmd>" {
  export CFENV_VERSION="2.0"

  create_ruby_executable
  create_executable "rake" <<SH
#!/usr/bin/env ruby
echo hello rake
SH

  cfenv-rehash
  run ruby -S rake
  assert_success "hello rake"
}

@test "supports ruby -S with system version" {
  export CFENV_VERSION=2.0
  create_executable "ruby" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"
  cfenv-rehash

  create_ruby_executable "${CFENV_TEST_DIR}/bin/ruby"
  create_executable "${CFENV_TEST_DIR}/bin/rake" <<SH
#!/usr/bin/env ruby
echo system rake
SH

  CFENV_VERSION=system run ruby -S rake
  assert_success "system rake"
}

@test "ruby -S allows commands higher in PATH to have precedence over shims" {
  export CFENV_VERSION="2.0"

  create_ruby_executable
  create_executable "rake" <<SH
#!/usr/bin/env ruby
echo normal rake
SH
  cfenv-rehash

  create_executable "${HOME}/bin/rake" <<SH
#!/usr/bin/env ruby
echo override rake
SH

  PATH="${HOME}/bin:$PATH" run ruby -S rake
  assert_success "override rake"
}

@test "ruby -S respects existing RUBYPATH" {
  export CFENV_VERSION="2.0"

  create_ruby_executable
  create_executable "rspec" <<SH
#!/usr/bin/env ruby
echo normal rspec
SH
  cfenv-rehash

  create_executable "${HOME}/bin/rspec" "#!/bin/sh"
  create_executable "${HOME}/bin/rake" <<SH
#!/usr/bin/env ruby
echo override rake
SH

  export RUBYPATH="${HOME}/bin"
  run ruby -S rspec
  assert_success "normal rspec"
  run ruby -S rake
  assert_success "override rake"
}

@test "supports nested ruby -S invocations to change CFENV_VERSION" {
  export CFENV_VERSION="1.8"
  create_ruby_executable
  create_executable "rspec" <<SH
#!/usr/bin/env ruby
echo rspec 1.8
SH

  export CFENV_VERSION="2.0"
  create_ruby_executable
  create_executable "rspec" <<SH
#!/usr/bin/env ruby
echo rspec 2.0
SH
  create_executable "rake" <<SH
#!/usr/bin/env ruby
echo rake 2.0
CFENV_VERSION=1.8 ruby -S rspec
SH

  cfenv-rehash
  run ruby -S rake
  assert_success
  assert_output <<OUT
rake 2.0
rspec 1.8
OUT
}

@test "supports system ruby -S invocation to select a different CFENV_VERSION" {
  export CFENV_VERSION="2.0"
  create_ruby_executable
  create_executable "rspec" <<SH
#!/usr/bin/env ruby
echo rspec 2.0
SH
  cfenv-rehash

  create_ruby_executable "${CFENV_TEST_DIR}/bin/ruby"
  create_executable "${CFENV_TEST_DIR}/bin/rspec" <<SH
#!/usr/bin/env ruby
echo system rspec
SH
  create_executable "${CFENV_TEST_DIR}/bin/rake" <<SH
#!/usr/bin/env ruby
echo system rake
CFENV_VERSION=2.0 ruby -S rspec
SH

  CFENV_VERSION=system run ruby -S rake
  assert_success
  assert_output <<OUT
system rake
rspec 2.0
OUT
}

@test "nested ruby -S invocations preserve PATH precedence" {
  export CFENV_VERSION="2.0"
  create_ruby_executable
  create_executable "rspec" <<SH
#!/usr/bin/env ruby
echo rspec 2.0
SH
  cfenv-rehash

  create_ruby_executable "${CFENV_TEST_DIR}/bin/ruby"
  create_executable "${CFENV_TEST_DIR}/bin/rspec" <<SH
#!/usr/bin/env ruby
echo system rspec
SH
  create_executable "${CFENV_TEST_DIR}/bin/rake" <<SH
#!/usr/bin/env ruby
echo system rake
CFENV_VERSION=2.0 ruby -S rspec
SH

  create_executable "${HOME}/bin/rspec" <<SH
#!/usr/bin/env ruby
echo override rspec
SH

  PATH="${HOME}/bin:$PATH" CFENV_VERSION=system run ruby -S rake
  assert_success
  assert_output <<OUT
system rake
override rspec
OUT
}
