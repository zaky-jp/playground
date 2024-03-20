# @fail fast
(( ${+PLAYGROUND_DIR} )) || { echo "error: PLAYGROUND_DIR is not defined." && exit 2; }
(( ${+XDG_CONFIG_HOME} )) || { echo "error: XDG_CONFIG_HOME is not defined." && exit 2; }
# @end

# @define environment variables
typeset -g ALACRITTY_HOME="${XDG_CONFIG_HOME}/alacritty"
typeset -gA alacritty_config
alacritty_config[alacritty.toml]="${PLAYGROUND_DIR}/alacritty/alacritty.toml"
alacritty_config[hints.toml]="${PLAYGROUND_DIR}/alacritty/${RUNOS}/hints.toml"
alacritty_config[shell.toml]="${PLAYGROUND_DIR}/alacritty/${RUNOS}/shell.toml.${RUNARCH}"
alacritty_config[env.zsh]="${PLAYGROUND_DIR}/alacritty/.env.zsh"
alacritty_config[rc.zsh]="${PLAYGROUND_DIR}/alacritty/.rc.zsh"
# @end