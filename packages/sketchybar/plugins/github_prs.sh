#!/bin/bash
# GitHub PR レビュー待ち数を表示するプラグイン

COUNT=$(gh search prs --review-requested=@me --state=open --json number --jq 'length' -- 'archived:false' 2>/dev/null)

COUNT="${COUNT:-0}"

# 件数に応じて色を変える
if [ "$COUNT" -ge 5 ]; then
  COLOR=0xffff6961   # 赤 - やばい
elif [ "$COUNT" -ge 3 ]; then
  COLOR=0xffffd966   # 黄 - そろそろ
else
  COLOR=0xffffffff   # 白 - 余裕
fi

sketchybar --set "$NAME" \
  drawing=on \
  label="${COUNT}" \
  icon.color="$COLOR" \
  label.color="$COLOR"
