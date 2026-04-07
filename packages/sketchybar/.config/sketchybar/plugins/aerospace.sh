#!/usr/bin/env bash
# ワークスペースのフォーカス状態を視覚化する

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
MIN_WORKSPACE=${MIN_WORKSPACE:-1}
MAX_WORKSPACE=${MAX_WORKSPACE:-9}

get_focused_workspace() {
  if command -v aerospace >/dev/null 2>&1; then
    aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | tr -d '\n' | tr -d ' ' || echo ""
  else
    echo ""
  fi
}

FOCUSED_WORKSPACE="$(get_focused_workspace)"

for sid in $(seq $MIN_WORKSPACE $MAX_WORKSPACE); do
  if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "space.$sid" \
      icon.color=0xFFFFFFFF \
      icon.font="Hack Nerd Font:Bold:16.0" \
      background.drawing=off
    sketchybar --set "space.$sid.underline" \
      drawing=on \
      background.drawing=on
  else
    sketchybar --set "space.$sid" \
      icon.color=0x88FFFFFF \
      icon.font="Hack Nerd Font:Semibold:16.0" \
      background.drawing=off
    sketchybar --set "space.$sid.underline" \
      drawing=off \
      background.drawing=off
  fi
done
