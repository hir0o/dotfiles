#!/bin/bash
battery_info="$(pmset -g batt 2>/dev/null)"

if [ -z "$battery_info" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

PERCENTAGE="$(echo "$battery_info" | awk '/InternalBattery/ {for(i=1;i<=NF;i++) if($i ~ /^[0-9]+%/) {gsub(/[^0-9]/,"",$i); print $i; exit}}')"

if echo "$battery_info" | grep -q 'AC Power'; then
  CHARGING="1"
else
  CHARGING=""
fi

if [ -z "$PERCENTAGE" ] || [ "$PERCENTAGE" -lt 0 ] || [ "$PERCENTAGE" -gt 100 ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *) ICON="" ;;
esac

if [ -n "$CHARGING" ]; then
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" drawing=on
