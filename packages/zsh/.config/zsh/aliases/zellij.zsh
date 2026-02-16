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

# worktreeをfzfで選んでZellijの新しいタブ（左右ペイン）で開く
zwt() {
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$git_root" ]]; then
    echo "Not a git repository"
    return 1
  fi

  local wt_dir="$git_root/.worktrees"
  if [[ ! -d "$wt_dir" ]]; then
    echo "No .worktrees directory found"
    return 1
  fi

  local selected=$(
    find "$wt_dir" -mindepth 2 -maxdepth 2 -type d | \
    sed "s|$wt_dir/||" | \
    fzf --preview "cat $wt_dir/{}/.worktree-purpose 2>/dev/null || echo '(no purpose file)'"
  )

  if [[ -n "$selected" ]]; then
    local wt_path="$wt_dir/$selected"
    zellij action new-tab --layout ~/.config/zellij/layouts/worktree.kdl --cwd "$wt_path" --name "$selected"
  fi
}

# Zellijのpipe機能を使用（プラグイン間でデータを送信）
function zpipe () {
  if [ -z "$1" ]; then
    zellij pipe;
  else
    zellij pipe -p $1;
  fi
}
