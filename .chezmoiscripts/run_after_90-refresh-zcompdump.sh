#!/usr/bin/env bash
# Rebuild the zsh completion dump when the set of completion files changes.
# Fingerprint = file names plus the first line ("#compdef ...") of every _* file
# in the extra fpath directories.
set -Eeuo pipefail
trap 'echo >&2 "zcompdump refresh failed (line ${LINENO})"' ERR
export LC_ALL=C

readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
readonly STAMP="$CACHE_DIR/completion-fingerprint"
readonly COMP_DIRS=(
  "$HOME/.local/share/zsh/plugins/zsh-completions/src"
  "$HOME/.local/share/zsh/site-functions"
)

fingerprint() {
  local dir
  for dir in "${COMP_DIRS[@]}"; do
    [[ -d $dir ]] || continue
    # One grep per directory: "<file>:<first line>"; no match is not an error
    grep -m1 -H '' "$dir"/_* 2> /dev/null || true
  done | cksum
}

main() {
  local current previous=""
  current="$(fingerprint)"
  [[ ! -f $STAMP ]] || previous="$(< "$STAMP")"
  if [[ $current != "$previous" ]]; then
    mkdir -p "$CACHE_DIR"
    rm -f "$CACHE_DIR"/zcompdump*
    printf '%s\n' "$current" > "$STAMP"
  fi
}

main
