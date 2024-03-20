if (( ${+commands[byobu]} )) && [[ ${TERM_PROGRAM:-} != "vscode" ]]; then
  byobu
fi