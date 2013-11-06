if [[ ! -o interactive ]]; then
    return
fi

compctl -K _cfenv cfenv

_cfenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(cfenv commands)"
  else
    completions="$(cfenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
