# Zellij aliases

# Launch Zellij
alias zj='zellij'

# Attach to a Zellij session selected with fzf
alias zja='zellij attach $(zellij list-sessions | fzf --ansi | sed -E "s/\x1b\[[0-9;]*m//g" | awk "{print \$1}")'

# Zellij helper functions
function zr () { zellij run --name "$*" -- zsh -ic "$*";}
function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}
function zri () { zellij run --name "$*" --in-place -- zsh -ic "$*";}
function ze () { zellij edit "$*";}
function zef () { zellij edit --floating "$*";}
function zei () { zellij edit --in-place "$*";}
function zpipe () {
  if [ -z "$1" ]; then
    zellij pipe;
  else
    zellij pipe -p $1;
  fi
}
