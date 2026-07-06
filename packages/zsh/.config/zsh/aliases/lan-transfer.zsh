# 同一LAN内での直接ファイル転送 (netcat / 古のやり方)
#
# 外部中継を介さず nc で直結するため高速・第三者を経由しない。
# 信頼できるLAN内が前提のため暗号化はしない。
#
# 送信: lan-send <file_or_dir>...
#   送信側が待ち受け、受信コマンド(自分のIP:ポート)を表示&クリップボードにコピー。
#   受信側はそのコマンドをコピペで実行するだけ。
# 受信: lan-recv <ip> <port>   (通常は表示コマンドのコピペでOK。手動受信用)

function lan-send() {
  if [ $# -eq 0 ]; then
    echo "Usage: lan-send <file_or_dir>..." >&2
    return 1
  fi

  local cmd
  for cmd in nc tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "lan-send: '$cmd' が見つかりません。PATH を確認してください" >&2
      return 1
    fi
  done

  # 自分のローカルIPを取得 (en0=Wi-Fi を優先, なければ有線等)
  local ip iface port recv_cmd
  for iface in en0 en1 en2 en3; do
    ip="$(ipconfig getifaddr "$iface" 2>/dev/null)"
    [ -n "$ip" ] && break
  done
  if [ -z "$ip" ]; then
    echo "lan-send: ローカルIPを取得できませんでした (Wi-Fi/有線に接続していますか)" >&2
    return 1
  fi

  # 50000-59999 のランダムポート (RANDOM は zsh 組み込み)
  port=$(( 50000 + RANDOM % 10000 ))
  recv_cmd="nc ${ip} ${port} | tar zxpf - -C ."

  echo ""
  echo "===== 受信コマンド (同じLAN内の別端末で実行) ====="
  echo "${recv_cmd}"
  echo "================================================="

  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "${recv_cmd}" | command pbcopy
    echo "(クリップボードにコピーしました)"
  fi

  echo ""
  echo "受信待機中 (${ip}:${port})... (Ctrl-C で中断)"

  # pv があれば進捗(転送量・速度・ETA)を表示。tar(無圧縮)→pv→gzip の順で
  # 通すことで、転送元の総サイズを基準にした正確な % を出せる。
  if command -v pv >/dev/null 2>&1; then
    local total
    total=$(du -sk "$@" 2>/dev/null | awk '{s+=$1} END{print s*1024}')
    tar cf - "$@" | pv -s "${total:-0}" | gzip | nc -l "${port}"
  else
    echo "(進捗表示には pv が必要です: brew install pv)"
    tar zcf - "$@" | nc -l "${port}"
  fi
}

function lan-recv() {
  if [ $# -ne 2 ]; then
    echo "Usage: lan-recv <ip> <port>" >&2
    return 1
  fi
  nc "$1" "$2" | tar zxpf - -C .
}

