alias vial='nvim `ls -d ${DOTPATH}/aliases/* | fzf --preview "bat --color=always --style=header,grid {}"`'
alias sral='source `ls -d ${DOTPATH}/aliases/* | fzf --preview "bat --color=always --style=header,grid {}"`'
alias fmv='fzf --multi | xargs -I{} mv {}'

alias c="cursor"
alias v="code"
alias nr="ni run"