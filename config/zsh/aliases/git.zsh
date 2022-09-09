alias g='git'
alias cg='cd $(ghq root)/$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")'
alias cgp='cd `ls -d ~/projects/*/* | sed "/\./d" | fzf --preview "bat --color=always --style=header,grid --line-range :80 {}/README.*"`'
alias ccg='code $(ghq root)/$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")'
