if (( ${+commands[volta]} )); then
  export VOLTA_HOME="$XDG_CONFIG_HOME/volta"
  path.push "$VOLTA_HOME/bin"
fi