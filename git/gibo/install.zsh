#!/usr/bin/env zsh
set -eu

# @define environment variables

# @end

# @define check function
function check_gibo_installed {
  case $RUNOS in
    macos)
      check_formula_installed_with_brew gibo
      return $?
      ;;
    *)
      return 1
  esac
}

# @define install function
function install_gibo_with_brew {
  brew install gibo 
}

function install_gibo() {
  if check_gibo_installed; then
    echo "warning: gibo is already installed."
    return 0
  fi
  case $RUNOS in
    macos)
      install_gibo_with_brew
      ;;
    *)
      echo "error: unsupported platform."
      return 1
  esac
}

# @run
echo "info: installing gibo..."
install_gibo
