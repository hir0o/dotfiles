# Zellij aliases

# Launch Zellij
alias zj='zellij'

# Attach to a Zellij session selected with fzf
alias zja='zellij attach $(zellij list-sessions | fzf --ansi | sed -E "s/\x1b\[[0-9;]*m//g" | awk "{print \$1}")'

# Zellij helper functions

# 新しいペインでコマンドを実行
function zr () { zellij run --name "$*" -- zsh -ic "$*";}

# フローティングペインでコマンドを実行
function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}

# 現在のペインを置き換えてコマンドを実行
function zri () { zellij run --name "$*" --in-place -- zsh -ic "$*";}

# 新しいペインでファイルを編集
function ze () { zellij edit "$*";}

# フローティングペインでファイルを編集
function zef () { zellij edit --floating "$*";}

# 現在のペインを置き換えてファイルを編集
function zei () { zellij edit --in-place "$*";}

# Zellijのpipe機能を使用（プラグイン間でデータを送信）
function zpipe () {
  if [ -z "$1" ]; then
    zellij pipe;
  else
    zellij pipe -p $1;
  fi
}
