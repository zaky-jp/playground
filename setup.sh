#!/usr/bin/env bash
set -eu

# @define environment variables
export GITHUB_REPO="zaky-jp/playground"
# @end

# @override echo to output to stderr
# @output stderr
function echo() {
  builtin echo "$@" >&2
}
# @end

# @define check status functions
# @output status code
function check_zsh_presense () {
  which zsh 1>/dev/null 2>&1
  return $?
}

# @defube download functions
# @output stdout
function download_setup_script() {
  curl -sSfL "https://raw.githubusercontent.com/${GITHUB_REPO}/main/setup.zsh"
}

# @define install functions
# @output executables added
function install_apt_zsh() {
  sudo --preserve-env=DEBIAN_FRONTEND apt-get -y update
  sudo --preserve-env=DEBIAN_FRONTEND apt-get -y install zsh
  sudo locale-gen en_US.UTF-8
  sudo dpkg-reconfigure locales
}
# @end

# @run
if ! check_zsh_presense; then
  if [[ $(lsb_release --id --short) == 'Ubuntu' ]]; then
    export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-'readline'} # allowing programmatic access to apt-get
    echo "info: installing zsh..."
    install_apt_zsh
  else
    echo "error: zsh was not installed."
    echo "error: please manually install zsh to continue with the setup"
    exit 1
  fi
fi

download_setup_script | zsh
# @end