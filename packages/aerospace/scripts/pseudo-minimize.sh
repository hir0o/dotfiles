#!/usr/bin/env bash
# フォーカス中ウィンドウを隠しワークスペース（{WS}-hidden）へ退避する。
# hidden ワークスペース上で実行した場合は復帰動作にフォールバックする。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 現在のワークスペースを取得
current_ws="$(aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | head -n1 | tr -d '[:space:]')"
[ -n "$current_ws" ] || exit 0

# hidden 上で押した場合は復帰へフォールバック
if [[ "$current_ws" == *"-hidden" ]]; then
  "$SCRIPT_DIR/pseudo-restore.sh"
  exit 0
fi

base_ws="${current_ws%-hidden}"
[ -n "$base_ws" ] || exit 0

# フォーカス中ウィンドウID
win_id="$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | head -n1 | tr -d '[:space:]')"
[ -n "$win_id" ] || exit 0

hidden_ws="${base_ws}-hidden"

# hidden ワークスペースへ退避
aerospace move-node-to-workspace --window-id "$win_id" "$hidden_ws" 2>/dev/null || exit 0

# フォーカスを元のワークスペースに戻す（ビューが hidden に追従するのを防ぐ）
aerospace workspace "$base_ws" 2>/dev/null || true

# SketchyBar があれば通知
command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger aerospace_workspace_change || true
