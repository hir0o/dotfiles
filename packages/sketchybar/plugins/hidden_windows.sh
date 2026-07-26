#!/usr/bin/env bash
# 疑似ミニマイズ中ウィンドウのアイコンを表示し、クリックで復帰させる
set -euo pipefail

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
SCRIPT_SELF="$CONFIG_DIR/plugins/hidden_windows.sh"

SLOTS=${HIDDEN_ICON_SLOTS:-4}
ICON_WIDTH=${HIDDEN_ICON_WIDTH:-16}
ICON_HEIGHT=${HIDDEN_ICON_HEIGHT:-16}
ICON_SCALE=${HIDDEN_ICON_SCALE:-0.8}
ICON_BG_HEIGHT=${HIDDEN_ICON_BG_HEIGHT:-16}
ITEM_WIDTH=${HIDDEN_ITEM_WIDTH:-24}

escape_for_shell() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g' -e 's/`/\\`/g'
}

if ! command -v aerospace >/dev/null 2>&1; then
  sketchybar --set hidden drawing=off icon.drawing=off label="" label.drawing=off
  for slot in $(seq 1 "$SLOTS"); do
    sketchybar --set "hidden.icon${slot}" drawing=off icon.background.drawing=off icon.drawing=off click_script=""
  done
  exit 0
fi

focused_workspace() {
  aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | head -n1 | tr -d '[:space:]'
}

base_workspace() {
  local ws
  ws="$(focused_workspace)"
  ws="${ws%-hidden}"
  printf '%s\n' "$ws"
}

restore_window() {
  local win_id="$1"
  [ -n "$win_id" ] || exit 0

  local ws
  ws="$(base_workspace)"
  [ -n "$ws" ] || exit 0

  aerospace move-node-to-workspace --window-id "$win_id" "$ws" 2>/dev/null || exit 0
  sketchybar --trigger aerospace_workspace_change || true
}

if [ "${1:-}" = "restore" ]; then
  restore_window "${2:-}"
  exit 0
fi

WS="$(base_workspace)"

if [ -z "$WS" ]; then
  sketchybar --set hidden drawing=off icon.drawing=off label="" label.drawing=off
  for slot in $(seq 1 "$SLOTS"); do
    sketchybar --set "hidden.icon${slot}" drawing=off icon.background.drawing=off icon.drawing=off click_script=""
  done
  exit 0
fi

HIDDEN_WS="${WS}-hidden"

hidden_list=$(aerospace list-windows --workspace "$HIDDEN_WS" --format '%{window-id}|%{app-name}' 2>/dev/null || true)
hidden_count=$(printf '%s\n' "$hidden_list" | grep -c '|' || true)

if [ "$hidden_count" -eq 0 ]; then
  sketchybar --set hidden drawing=off icon.drawing=off label="" label.drawing=off
  for slot in $(seq 1 "$SLOTS"); do
    sketchybar --set "hidden.icon${slot}" drawing=off icon.background.drawing=off icon.drawing=off click_script=""
  done
  exit 0
fi

cmd=(sketchybar)
cmd+=(--set hidden drawing=off icon.drawing=off label="" label.drawing=off)

slot=1
while IFS='|' read -r win_id app_name; do
  [ -n "$win_id" ] || continue
  [ -n "$app_name" ] || app_name="Unknown"

  escaped_app=$(escape_for_shell "$app_name")

  [ "$slot" -le "$SLOTS" ] || break
  item="hidden.icon${slot}"
  cmd+=(--set "$item" \
    drawing=on \
    width="$ITEM_WIDTH" \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=on \
    background.image="app.${escaped_app}" \
    background.image.scale="$ICON_SCALE" \
    background.height="$ICON_BG_HEIGHT" \
    background.corner_radius=3 \
    background.y_offset=0 \
    padding_left=0 \
    padding_right=0 \
    click_script="$SCRIPT_SELF restore $win_id"
  )
  slot=$((slot + 1))
done <<<"$hidden_list"

while [ "$slot" -le "$SLOTS" ]; do
  item="hidden.icon${slot}"
  cmd+=(--set "$item" drawing=off icon.drawing=off icon.background.drawing=off click_script="")
  slot=$((slot + 1))
done

"${cmd[@]}"
