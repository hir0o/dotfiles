#!/bin/bash
days=(日 月 火 水 木 金 土)
day_of_week=$(date '+%w')
sketchybar --set "$NAME" label="$(date '+%m/%d')(${days[$day_of_week]})"
