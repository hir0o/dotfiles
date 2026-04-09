# brew wrapper: install/uninstall 後に補完キャッシュを自動更新
brew() {
  command brew "$@"
  if [[ "$1" == "install" || "$1" == "uninstall" ]]; then
    echo "Refreshing completions..."
    rm -f ${ZDOTDIR:-~}/.zcompdump*
    compinit
  fi
}
