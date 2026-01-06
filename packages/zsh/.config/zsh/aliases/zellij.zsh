# Zellij aliases

# Attach to a Zellij session selected with fzf
alias zja='zellij attach $(zellij list-sessions | fzf)'
