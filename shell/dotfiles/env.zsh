#log_level[debug]=1 #enable debug
#typeset -g ECHO_SHOW_CALLER=1 #enable debug
# @define fundamental variables
# XDG-related
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.run}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
# playground
export PLAYGROUND_DIR="${PLAYGROUND_DIR:-${HOME}/playground}"
# ZDOTDIR
export ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}"
# @end

# @override echo to output to stderr
# @output stderr
if ! (( $+functions[echo] )); then
  function echo() {
    builtin echo "$@" >&2
  }
fi
# @end

# @define store variables
(( ${+zsh_files} )) || typeset -Ag zsh_files
(( ${+zsh_libs} )) || typeset -Ag zsh_libs
# @end

# @define variable store functions
# @output variables modified
function zsh_files.push() {
  # fail fast
  if ! (( ${+zsh_files} )); then
    echo "error: zsh_files is not set."
    return 1
  fi

  # parse
  local key
  local file_path
  case $# in
    1)
      file_path=$1
      key=${file_path:t:r}
      ;;
    2)
      key=$1
      file_path=$2
      ;;
    *)
      echo "error: invalid number of arguments."
      return 1
      ;;
  esac

  if [[ -e $file_path ]]; then
    zsh_files[${key}]="${file_path}"
  else
    echo "debug: $file_path does not exist. skipping..."
  fi
}

function zsh_libs.push() {
  # fail fast
  if ! (( ${+zsh_libs} )); then
    echo "error: zsh_libs is not set."
    return 1
  fi

 # parse
  local lib_name
  local lib_path
  case $# in
    1)
      lib_path=$1
      lib_name=${lib_path:t:r:r} # expects xxx.env.zsh
      ;;
    2)
      lib_name=$1
      lib_path=$2
      ;;
    *)
      echo "error: invalid number of arguments."
      return 1
      ;;
  esac

  if (( ${+zsh_libs[${lib_name}]} )); then
    echo "debug: ${lib_name} already exists. skipping..."
  elif [[ -e $lib_path ]]; then
    zsh_libs[${lib_name}]="${lib_path}"
  else
    echo "debug: $lib_path does not exist. skipping..."
  fi
}

# @define get functions
function get_zshenv() {
  local -a zshenv_path
  zshenv_path+=('/etc/zsh/zshenv')
  zshenv_path+=('/etc/zshenv')

  for p in ${zshenv_path}; do
    if [[ -r $p ]]; then
      builtin echo $p
      break
    fi
  done
}

# @configure echo
# refer: shell/lib/echo.zsh
export ECHO_FD=2
# @end

# @run
# add zsh environment file paths
zsh_files.push "${PLAYGROUND_DIR}/shell/lib"
zsh_files.push 'env' "$(get_zshenv)"

# add zshlib file paths
() {
  emulate -L zsh -o extended_glob
  for f in "${zsh_files[lib]}"/*.env.zsh; do
    zsh_libs.push "${f:a}"
  done
}
() {
  emulate -L zsh -o extended_glob -o nonomatch
  for f in "${XDG_CONFIG_HOME}"/*/env.zsh; do
    zsh_libs.push "${f:a:h:t}" "${f:a}"
  done
}
zsh_libs.push 'brewpath' "${XDG_CONFIG_HOME}/brew/shellenv.zsh"

# source zsh_libs
source "${zsh_libs[source]}" # prioritise
source "${zsh_libs[echo]}" # prioritise
for lib in ${(k)zsh_libs}; do
  if [[ $lib == 'source' ]] || [[ $lib == 'echo' ]]; then
    continue
  fi
  source "${zsh_libs[${lib}]}"
done

# misc actions
LC_CTYPE="en_US.UTF-8"
LANG="en_US.UTF-8"

# path configuration
path.push "${XDG_BIN_HOME}"
path.clean
# @end
