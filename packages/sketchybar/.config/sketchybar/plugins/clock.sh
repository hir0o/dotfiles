#!/bin/bash
time_line=$(date '+%H:%M:%S')
time_line_fixed=$(printf '%-8s' "$time_line")
sketchybar --set "$NAME" label="$time_line_fixed"
