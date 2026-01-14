alias vial='nvim `ls -d ${XDG_CONFIG_HOME:-~/.config}/zsh/aliases/* | fzf --preview "bat --color=always --style=header,grid {}"`'
alias sral='source `ls -d ${XDG_CONFIG_HOME:-~/.config}/zsh/aliases/* | fzf --preview "bat --color=always --style=header,grid {}"`'
alias hals='ls ${XDG_CONFIG_HOME:-~/.config}/zsh/aliases/*.zsh | fzf --preview "bat --color=always {}"'
alias fmv='fzf --multi | xargs -I{} mv {}'

alias c="cursor"
alias v="code"
alias cc="claude --dangerously-skip-permissions"
alias nr="ni run"