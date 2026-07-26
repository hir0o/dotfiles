ZSH_PATH="$XDG_CONFIG_HOME/zsh"


# General
mkcd() { mkdir $@; cd $@; }
alias vz='nvim ${DOTPATH}/.zshrc'
alias srz='source ~/.zshrc'
alias ...='cd ../../'
alias op='open ./'
alias oplg='open https://github.com/hir0o/log/issues'
alias rmds='find . -name '.DS_Store' -type f -ls -delete'
alias ll='eza -alhF --icons --group-directories-first --time-style=long-iso'
alias bat='bat --color=always --style=header,grid'
alias cl='cd $(ls -d */ | fzf)'
alias edd='vim $(ghq root)/github.com/hir0o/dotfiles'
alias tma='tmux a || tmux'
alias py='python3'
alias b='bat'
alias vim='nvim'
alias opap='ls /Applications | fzf | xargs open -a'
alias pn='pnpm'

# Load all alias files
for alias_file in "$ZSH_PATH/aliases"/*.zsh(N); do
  source "$alias_file"
done

# anyenv
# eval "$(anyenv init -)"
export PATH="$HOME/.anyenv/bin:$PATH"

# Fuzzy
export PATH="$HOME/git-fuzzy/bin:$PATH"
export GIT_FUZZY_STATUS_ADD_KEY='Ctrl-A'
export GIT_FUZZY_STATUS_RESET_KEY='Ctrl-R'

# FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git' -g '!node_modules' --max-columns 200"
export FZF_DEFAULT_OPTS='--reverse --color fg:-1,bg:-1,hl:230,fg+:3,bg+:233,hl+:229 --color info:150,prompt:110,spinner:150,pointer:167,marker:174'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ban
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
