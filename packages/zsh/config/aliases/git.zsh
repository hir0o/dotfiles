alias g=git
alias lg=lazygit

# .worktrees/ 配下のworktreeをfzfで選んでcd
cw() {
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
    cd "$wt_dir/$selected"
  fi
}

# after-pushフックを実行
afp() {
  [ -f ./.local-hooks/after-push ] && bash ./.local-hooks/after-push || true
}

# PRのマージ（PR番号またはURLを指定可能）
pr-merge() {
  local pr_ref="$1"

  if [[ -z "$pr_ref" ]]; then
    echo "Usage: pr-merge <PR番号 or PR URL>"
    return 1
  fi

  gh pr checks "$pr_ref" --watch && gh pr merge "$pr_ref" --delete-branch --merge && say -v Kyoko "マージしました" || say -v Kyoko "アクション失敗しました"
}