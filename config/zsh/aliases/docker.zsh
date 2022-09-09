alias d='docker'
compdef _docker d
alias dc='docker-compose'
compdef _docker-compose dc

## ========== Docker ==========
alias d='docker'
alias dlsc='docker container ls'
alias dlsi='docker image ls'
alias dps='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias de='docker exec -it `dps | fzf | cut -f 1` /bin/bash'

## ========== Docker Compose ==========
alias dc='docker-compose'
alias dcb='docker-compose build'
alias dcu='docker-compose up'
alias dcbn='docker-compose build --no-cache'