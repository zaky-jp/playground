if (( $+commands[apt] )); then
  alias apt="sudo $commands[apt]"
  alias apt-get="sudo $commands[apt-get]"
fi