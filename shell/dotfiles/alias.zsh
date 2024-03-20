# rm
if (( $+commands[trash] )); then
  alias rm="trash"
fi

# ls
alias ls="ls -aAF --color=auto"
alias lsl="ls -aAFl@ --color=auto"

# mv
alias mv="mv -i"

# git
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gp="git push"
alias gd="git diff"
alias gds="git diff --staged"
