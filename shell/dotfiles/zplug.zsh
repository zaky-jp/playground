# prepare zplug
export ZPLUG_HOME="${XDG_DATA_HOME}/zsh/zplug"

## automatically install zplug unless set ZPLUG_AUTOINSTALL=0
ZPLUG_AUTOINSTALL=${ZPLUG_AUTOINSTALL:-1}
if (( ${ZPLUG_AUTOINSTALL} )); then
  if ! [[ -d "${ZPLUG_HOME}" ]]; then
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
  fi
fi

if [[ -d "${ZPLUG_HOME}" ]]; then
  export ZPLUG_CACHE_DIR="${XDG_CACHE_HOME}/zsh/zplug"
  source "${ZPLUG_HOME}/init.zsh"

  ## list plugins
  zplug "zplug/zplug", depth:1, hook-build:"zplug --self-manage"
  zplug "chrissicool/zsh-256color"
  zplug "zsh-users/zsh-syntax-highlighting", depth:1, defer:2
  zplug "zsh-users/zsh-autosuggestions", depth:1
  zplug "plugins/shrink-path", from:oh-my-zsh, depth:1
#  zplug "zaky-jp/globalias-augmented", depth:1, use:'globalias.plugin.zsh'
  zplug "endaaman/lxd-completion-zsh", depth:1, if:"(( $+commands[lxc] ))"
  zplug "romkatv/powerlevel10k", as:theme, depth:1

  ## make sure to install plugin
  zplug check || zplug install

  ## create precompiled files if needed
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in \
    ${ZPLUG_REPOS}/**/*.zsh(.) \
    ${ZPLUG_REPOS}/zplug/zplug/autoload/**/^*.zwc(.); do
      [[ $f.zwc -nt $f ]] || zcompile -R -- $f.zwc $f
    done
  }
fi