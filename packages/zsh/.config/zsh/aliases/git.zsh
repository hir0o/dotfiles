alias g=git
alias lg=lazygit

# after-pushフックを実行
afp() {
  [ -f ./.local-hooks/after-push ] && bash ./.local-hooks/after-push || true
}

# PRのマージ
alias pr-merge='f() { gh pr checks "$1" --watch && gh pr merge "$1" --delete-branch --merge && say -v Kyoko "マージしました" || say -v Kyoko "アクション失敗しました" }; f'