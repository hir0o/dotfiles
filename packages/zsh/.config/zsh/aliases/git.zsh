alias g=git

# after-pushフックを実行
afp() {
  [ -f ./.local-hooks/after-push ] && bash ./.local-hooks/after-push || true
}