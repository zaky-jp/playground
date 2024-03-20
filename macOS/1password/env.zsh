if [[ -e "${XDG_RUNTIME_DIR}/1password/agent.sock" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/1password/agent.sock"
fi