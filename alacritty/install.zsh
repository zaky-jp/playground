#!/usr/bin/env zsh
set -eu

# @fail fast
(( ${+RUNOS} )) || { echo "error: RUNOS is not defined." && exit 2; }
(( ${+RUNARCH} )) || { echo "error: RUNARCH is not defined." && exit 2; }
case $RUNOS in
  macos) 
    (( ${+commands[brew]} )) || { echo "error: homebrew is not found. aborting..."; exit 1; } ;;
  *)
    echo "error: This script does not support $RUNOS."
    exit 1
    ;;
esac
# @end  

# @define environment variables
source "${PLAYGROUND_DIR}/alacritty/.env.zsh"
# @end

# @define check functions
function check_alacritty_installed() {
  [[ -d "/Applications/Alacritty.app" ]]
  return $?
}

function check_sfmono_square_installed() {
  check_file_exist "/Library/Fonts/SFMonoSquare-Regular.otf"
  return $?
}
# @end

# @define install functions
function install_alacritty_with_brew() {
  if check_alacritty_installed; then
    echo "warning: alacritty is already installed."
    return
  fi
  echo "info: installing alacritty..."
  brew install --cask alacritty
}

function install_sfmono_square() {
  if check_sfmono_square_installed; then
    echo "warning: sfmono-square is already installed."
    return
  fi
  echo "info: installing sfmono-square..."
  brew install delphinus/sfmono-square/sfmono-square
}

function copy_sfmono_square_fonts() {
  if check_sfmono_square_installed; then
    echo "warning: sfmono-square is already installed."
    return
  fi
  echo "info: requesting sudo privilege to copy to /Library/Fonts"
  (){
    emulate -L zsh -o extended_glob
    sudo cp -i "${PLAYGROUND_DIR}/alacritty/SFMonoSquare-Regular.otf" /Library/Fonts
  }
}
# @end

# @define configure functions
function symlink_alacritty_configuration() {
  (( ${#alacritty_config} )) || { echo "error: alacritty_config is not defined." && return 2; }

  for target in ${(k)alacritty_config}; do
    if check_file_exist "${ALACRITTY_HOME}/$target"; then
      echo "warning: $target already exists."
      continue
    fi
    echo "debug: creating symlink for ${target}"
    ln -s "${alacritty_config[$target]}" "${ALACRITTY_HOME}/${target}"
  done
}

function rm_old_configuration() {
  local old_config="${ALACRITTY_HOME}/alacritty.yml"

  if check_file_exist $old_config; then
    echo "warning: obsolete config detected. removing."
    rm "${ALACRITTY_HOME}/alacritty.yml"
  fi
}

# @run
echo "info: start installing alacritty..."
echo "info: installing terminfo..."
bash "$PLAYGROUND_DIR/alacritty/terminfo.sh"
case $RUNOS in
  macos)
    echo "info: installing alacritty using brew..."
    install_alacritty_with_brew
    echo "info: installing fonts..."
    install_sfmono_square
    copy_sfmono_square_fonts
    defaults write org.alacritty AppleFontSmoothing -int 0 # enable font smoothing
    ;;
esac
echo "info: configuring alacritty..."
rm_old_configuration
symlink_alacritty_configuration
# @end
