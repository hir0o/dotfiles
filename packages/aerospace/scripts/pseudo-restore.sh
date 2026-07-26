#!/usr/bin/env bash
# 隠しワークスペース（{WS}-hidden）からウィンドウを1つ現在のワークスペースへ戻す。
set -euo pipefail

# 現在のワークスペースを取得
current_ws="$(aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | head -n1 | tr -d '[:space:]')"
[ -n "$current_ws" ] || exit 0

base_ws="${current_ws%-hidden}"
[ -n "$base_ws" ] || exit 0
hidden_ws="${base_ws}-hidden"

# hidden 側の先頭ウィンドウを1つ取得
win_id="$(aerospace list-windows --workspace "$hidden_ws" --format '%{window-id}' 2>/dev/null | head -n1 | tr -d '[:space:]' || true)"
[ -n "$win_id" ] || exit 0

# ベースワークスペースへ戻す
aerospace move-node-to-workspace --window-id "$win_id" "$base_ws" 2>/dev/null || exit 0

# 戻したウィンドウにフォーカスする
aerospace focus --window-id "$win_id" 2>/dev/null || true

# SketchyBar があれば通知
command -v sketchybar >/dev/null 2>&1 && sketchybar --trigger aerospace_workspace_change || true
