#!/usr/bin/env bash
set -eu

# @define environment variables
ALACRITTY_TERMINFO="${PLAYGROUND_DIR}/alacritty/upstream/extra/alacritty.info"
# @end

# @fail fast
[[ ${PLAYGROUND_DIR:+foo} ]] || { echo "PLAYGROUND_DIR is not set"; exit 2; }
[[ -e "$ALACRITTY_TERMINFO" ]] || { echo "error: ALACRITTY_TERMINFO is not found"; exit 2; }
# @end

# @define check functions
function check_alacritty_terminfo() {
  infocmp alacritty >/dev/null 2>&1
  return $?
}
# @end

# @define configure function
function create_terminfo() {
  if check_alacritty_terminfo; then
    echo "debug: terminfo already installed"
    return
  fi
  tic -xe alacritty,alacritty-direct "${ALACRITTY_TERMINFO}"
}

# @run
create_terminfo
# @end
