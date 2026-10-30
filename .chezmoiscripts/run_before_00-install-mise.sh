#!/usr/bin/env bash
# Install mise into ~/.local/bin and refresh it with "mise self-update" about once a week.
# Export MISE_VERSION to pin a version; the periodic self-update is then skipped.
set -Eeuo pipefail
trap 'msg "mise setup failed (line ${LINENO})"' ERR

readonly MISE_BIN="$HOME/.local/bin/mise"
readonly STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/mise-self-update.stamp"
readonly UPDATE_INTERVAL_DAYS=7

msg() {
  echo >&2 -e "${1-}"
}

touch_stamp() {
  mkdir -p "${STAMP%/*}"
  touch "$STAMP"
}

install_mise() {
  msg "Installing mise to $MISE_BIN"
  mkdir -p "${MISE_BIN%/*}"
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$MISE_BIN" sh
}

update_due() {
  [[ ! -f $STAMP ]] || [[ -n $(find "$STAMP" -mtime +"$UPDATE_INTERVAL_DAYS" -print) ]]
}

self_update() {
  # A failed update (offline, rate limit) must not break "chezmoi apply"
  if "$MISE_BIN" self-update --yes; then
    touch_stamp
  else
    msg "mise self-update failed; retrying on the next apply"
  fi
}

main() {
  if [[ ! -x $MISE_BIN ]]; then
    install_mise
    touch_stamp
  elif [[ -z ${MISE_VERSION:-} ]] && update_due; then
    self_update
  fi
}

main
