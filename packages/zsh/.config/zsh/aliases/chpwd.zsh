# ディレクトリ変更時に自動実行されるフック関数
# カレントディレクトリに .localrc があれば自動で読み込む

chpwd() {
  # カレントディレクトリに.localrcがあれば実行
  if [[ -f .localrc ]]; then
    source .localrc
  fi
}
