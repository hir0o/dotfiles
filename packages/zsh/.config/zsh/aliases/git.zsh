alias g=git
alias lg=lazygit

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