#!/usr/bin/env zsh
set -eu

# @fail fast
(( ${+PLAYGROUND_DIR} )) || { echo "error: PLAYGROUND_DIR is not defined." && exit 2; }
case $RUNOS in
  macos)
    (( ${+commands[brew]} )) || { echo "error: homebrew is not found. aborting..."; exit 1; } ;;
  ubuntu)
    ;;
  *)
    echo "error: This script does not support $RUNOS."
    exit 1
    ;;
esac
# @end

# @define environment variables
source "${PLAYGROUND_DIR}/git/.env.zsh"
# @end

# @define configure function
function mkdir_config_home {
  mkdir -p "${XDG_CONFIG_HOME}/git"
}

function symlink_gitignore {
  mkdir_config_home
	if check_file_exist "$gitignore_global"; then
		echo "warning: $gitignore_global already exists."
		return 0
	fi
  ln -s "${PLAYGROUND_DIR}/git/ignore" "$gitignore_global"
}

# @run
echo "info: configuring git..."
for key in ${(k)git_config}; do
  git config --global "${key}" "${git_config[${key}]}"
done
echo "info: configuring global gitignore..."
symlink_gitignore
# @end