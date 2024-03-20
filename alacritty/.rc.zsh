if (( $+commands[alacritty] )); then
  function ssh() {
    local arg=$1
    echo "Starting ssh in a new alacritty window:"
    if [[ $arg == '--emulate-xterm' ]]; then
      # TERM variable is always send to the remote server
      # this means alacritty.terminfo needs to be present at remote server
      # otherwise needs to emulate xterm-256color to achieve true colour
      shift
      eval alacritty msg create-window --hold --command "zsh -i -c 'TERM=xterm-256color command ssh $@'"
    else
      eval alacritty msg create-window --hold --command "zsh -i -c 'command ssh $@'"
    fi
  }
fi