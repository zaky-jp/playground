# @fail fast
(( ${+PLAYGROUND_DIR} )) || { echo "error: PLAYGROUND_DIR is not defined." && exit 2; }
(( ${+XDG_DATA_HOME} )) || { echo "error: XDG_DATA_HOME is not defined." && exit 2; }
# @end

# define environment variables
typeset -gA git_config
git_config[user.name]='Rintaro Kanzaki'
git_config[user.email]='105104188+zaky-jp@users.noreply.github.com'
typeset -g gitignore_global="${XDG_CONFIG_HOME}/git/ignore"

if (( ${+commands[gibo]} )); then
  typeset -g GIBO_BOILERPLATES="${XDG_DATA_HOME}/gibo"
fi
# @end