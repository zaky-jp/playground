# @define environment variables
typeset -gA brew_config
brew_config[env.zsh]="${PLAYGROUND_DIR}/brew/.env.zsh"
brew_config[rc.zsh]="${PLAYGROUND_DIR}/brew/.rc.zsh"

typeset -gA brew_cache
brew_cache[formulae]="${XDG_CACHE_HOME}/brew/formulae.zsh"
brew_cache[casks]="${XDG_CACHE_HOME}/brew/casks.zsh"
# @end

# @run
source "$brew_cache[formulae]"
source "$brew_cache[casks]"