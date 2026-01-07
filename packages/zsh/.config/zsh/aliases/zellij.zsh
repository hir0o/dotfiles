# Zellij aliases

# Launch Zellij
alias zj='zellij'

# Attach to a Zellij session selected with fzf
alias zja='zellij attach $(zellij list-sessions | fzf --ansi | sed -E "s/\x1b\[[0-9;]*m//g" | awk "{print \$1}")'
