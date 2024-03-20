if (( ${+commands[editor]} )); then
  export EDITOR=editor # fallback to update-alternatives
elif (( ${+commands[nvim]} )); then
  export EDITOR=nvim
else
  export EDTIOR=vi # fallback to vi
fi