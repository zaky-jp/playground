# @define store variables
(( ${#zsh_rcs} )) || typeset -Ag zsh_rcs
# @end

# @define variable store functions
# @output variables modified
function zsh_rcs.push() {
  # fail fast
  if ! (( ${+zsh_rcs} )); then
    echo "error: zsh_rcs is not set."
    return 1
  fi

 # parse
  local rc_name
  local rc_path
  case $# in
    1) 
      rc_path=$1
      rc_name=${rc_path:t:r:r} # expects xxx.rc.zsh
      ;;
    2)
      rc_name=$1
      rc_path=$2
      ;;
    *)
      echo "error: invalid number of arguments."
      return 1
      ;;
  esac

  if (( ${+zsh_rcs[${rc_name}]} )); then
    echo "debug: ${rc_name} already exists. skipping..."
  elif [[ -e $rc_path ]]; then
    zsh_rcs[${rc_name}]="${rc_path}"
  else
    echo "debug: $rc_path does not exist. skipping..."
  fi
}

function generate_comp_cache() {
  local compdump="${ZDOTDIR}/.zcompdump"
  if ! [[ -r "$compdump".zwc ]] || [[ "$compdump" -nt "$compdump".zwc ]]; then
    zcompile -R ${compdump}{.zwc,}
  fi
}

# @run
# use powerlevel10k instant prompt (should source first)
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# add zshrc file paths
() {
  emulate -L zsh -o extended_glob
  for f in "${zsh_files[lib]}"/*.rc.zsh; do
    zsh_rcs.push "${f:a}"
  done
}
() {
  emulate -L zsh -o extended_glob -o nonomatch
  for f in "${XDG_CONFIG_HOME}"/*/rc.zsh; do
    zsh_rcs.push "${f:a:h:t}" "${f:a}"
  done
}
zsh_rcs.push "${PLAYGROUND_DIR}/shell/p10k/powerlevel10k.zsh-theme"
zsh_rcs.push "${PLAYGROUND_DIR}/shell/dotfiles/p10k.zsh"
zsh_rcs.push "${PLAYGROUND_DIR}/shell/dotfiles/alias.zsh"

# source zsh_rcs
for rc in ${(k)zsh_rcs}; do
  source "${zsh_rcs[${rc}]}"
done

# completion
fpath.push "${HOMEBREW_PREFIX}/share/zsh/site-functions"
fpath.clean
autoload -Uz compinit && compinit -u
generate_comp_cache
# @end
