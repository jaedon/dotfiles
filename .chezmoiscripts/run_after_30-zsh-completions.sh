#!/usr/bin/env bash
# Generate zsh completions for CLI tools into ~/.local/share/zsh/site-functions.
# Runs on every apply: generation is local and fast, and it follows "mise upgrade".
set -Eeuo pipefail
trap 'echo >&2 "zsh completion setup failed (line ${LINENO})"' ERR

readonly MISE_BIN="$HOME/.local/bin/mise"
readonly COMP_DIR="$HOME/.local/share/zsh/site-functions"

msg() {
  echo >&2 -e "${1-}"
}

# mise may be missing when an earlier step failed; do not add noise
[[ -x $MISE_BIN ]] || exit 0

# Tools installed by mise are reachable through its shims
export PATH="$HOME/.local/share/mise/shims:$PATH"
mkdir -p "$COMP_DIR"

# gen <completion-file> <command...>
# Installs the command's stdout as a completion file. A tool that is missing,
# fails, or prints no "#compdef" header (help text, errors) is skipped.
gen() {
  local name=$1
  shift
  local tmp
  tmp="$(mktemp)"
  if "$@" > "$tmp" 2> /dev/null && grep -q '^#compdef' "$tmp"; then
    install -m 0644 "$tmp" "$COMP_DIR/$name"
  else
    msg "skipped zsh completion: $name"
  fi
  rm -f "$tmp"
}

gen _chezmoi chezmoi completion zsh
gen _fd fd --gen-completions zsh
gen _gh gh completion -s zsh
gen _mise "$MISE_BIN" completion zsh
gen _rclone rclone completion zsh -
gen _rg rg --generate complete-zsh
gen _starship starship completions zsh
gen _uv uv generate-shell-completion zsh
gen _uvx uvx --generate-shell-completion zsh
