#!/bin/bash
# Raycast Project Timer の稼働状況を表示するプラグイン
# 拡張が書き出す ~/.cache/project-timer/status.json を読み、稼働中のみ経過時間を毎秒表示する。

STATUS_FILE="$HOME/.cache/project-timer/status.json"

# ファイルが無い / 稼働していないなら非表示にして終了
if [ ! -f "$STATUS_FILE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

ACTIVE=$(jq -r '.active // false' "$STATUS_FILE" 2>/dev/null)
if [ "$ACTIVE" != "true" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

PROJECT_NAME=$(jq -r '.name // ""' "$STATUS_FILE")
PROJECT_ICON=$(jq -r '.icon // ""' "$STATUS_FILE")
BASE_MS=$(jq -r '.baseMs // 0' "$STATUS_FILE")
STARTED_AT=$(jq -r '.startedAt // 0' "$STATUS_FILE")

# 経過ミリ秒 = 累計 + (現在 - 開始)。負値は 0 に丸める。
NOW_MS=$(( $(date +%s) * 1000 ))
ELAPSED_MS=$(( BASE_MS + NOW_MS - STARTED_AT ))
[ "$ELAPSED_MS" -lt 0 ] && ELAPSED_MS=0

TOTAL_SEC=$(( ELAPSED_MS / 1000 ))
H=$(( TOTAL_SEC / 3600 ))
M=$(( (TOTAL_SEC % 3600) / 60 ))
S=$(( TOTAL_SEC % 60 ))
TIME=$(printf '%02d:%02d:%02d' "$H" "$M" "$S")

LABEL="$PROJECT_NAME $TIME"
[ -n "$PROJECT_ICON" ] && LABEL="$PROJECT_ICON $LABEL"

sketchybar --set "$NAME" \
  drawing=on \
  icon="▶" \
  label="$LABEL"
