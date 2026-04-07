#!/usr/bin/env bash
# シンプルで高速なワークスペースアイコン更新スクリプト

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
SKETCHYBAR_BIN="${BAR_NAME:-sketchybar}"

if [ -z "${WINDOW_SNAPSHOT:-}" ]; then
  WINDOW_SNAPSHOT=""
fi

case "${SENDER:-}" in
  ""|poll|timer|routine|forced) ;;
  aerospace_workspace_change|front_app_switched) ;;
  *) exit 0 ;;
esac

DEFAULT_MIN_WORKSPACE=1
DEFAULT_MAX_WORKSPACE=9
MIN_WORKSPACE=${MIN_WORKSPACE:-$DEFAULT_MIN_WORKSPACE}
MAX_WORKSPACE=${WORKSPACE_RANGE_MAX:-${MAX_WORKSPACE:-$DEFAULT_MAX_WORKSPACE}}
EXTRA_WORKSPACES="${EXTRA_WORKSPACES:-}"

VISIBLE_ICON_SLOTS=${VISIBLE_ICON_SLOTS:-4}
ICON_WIDTH=${ICON_WIDTH:-16}
ICON_HEIGHT=${ICON_HEIGHT:-16}
ICON_ITEM_WIDTH=${ICON_ITEM_WIDTH:-24}
ICON_IMAGE_SCALE=${ICON_IMAGE_SCALE:-0.8}

SEP=$'\034'

trim() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

normalize_ws() {
  local s; s="$(trim "$1")"
  [ -n "$s" ] || return 1
  printf '%s\n' "$s"
}

is_supported_ws() {
  local ws="$1"
  case "$ws" in
    '' ) return 1 ;;
    *[!0-9]* ) ;;
    * )
      [ "$ws" -ge "$MIN_WORKSPACE" ] && [ "$ws" -le "$MAX_WORKSPACE" ]
      return $? ;;
  esac

  local extra
  for extra in $EXTRA_WORKSPACES; do
    [ "$ws" = "$extra" ] && return 0
  done
  return 1
}

workspace_list() {
  local list=()
  local i
  for ((i=MIN_WORKSPACE; i<=MAX_WORKSPACE; i++)); do
    list+=("$i")
  done
  for i in $EXTRA_WORKSPACES; do
    list+=("$i")
  done
  printf '%s\n' "${list[@]}"
}

parse_info_tokens() {
  [ -n "${INFO:-}" ] || return 0
  printf '%s' "$INFO" | tr -c '[:alnum:]' ' ' | awk '{for(i=1;i<=NF;i++)print $i}'
}

update_workspace_icons() {
  local workspace="$1" total_count="$2" apps_joined="$3"

  local cmd=("$SKETCHYBAR_BIN")
  cmd+=(--set "space.$workspace" drawing=on icon="$workspace" icon.drawing=on)

  local apps_arr=() shown=0
  if [ -n "$apps_joined" ]; then
    IFS="$SEP" read -r -a apps_arr <<<"$apps_joined"
    shown=${#apps_arr[@]}
  fi

  local extra_count=0
  if [ "$total_count" -gt "$shown" ]; then
    extra_count=$(( total_count - shown ))
  fi

  local slot=1
  while [ "$slot" -le "$VISIBLE_ICON_SLOTS" ]; do
    local item="space.$workspace.icon$slot"
    if [ "$slot" -le "$shown" ]; then
      local app="${apps_arr[$((slot-1))]}"
      cmd+=(--set "$item"
        drawing=on
        width="$ICON_ITEM_WIDTH"
        icon=" "
        icon.drawing=on
        "icon.background.image=app.$app"
        icon.background.drawing=on
        "icon.background.image.scale=$ICON_IMAGE_SCALE"
        icon.background.corner_radius=3
        "icon.background.height=$ICON_HEIGHT"
        icon.background.y_offset=0
        icon.padding_left=2
        icon.padding_right=2
        "icon.width=$ICON_WIDTH"
        label=""
        label.drawing=off
      )
    else
      cmd+=(--set "$item"
        drawing=off
        width=0
        padding_left=0
        padding_right=0
        icon=""
        icon.drawing=off
        icon.background.drawing=off
      )
    fi
    slot=$((slot + 1))
  done

  if [ "$extra_count" -gt 0 ]; then
    cmd+=(--set "space.$workspace.more"
      drawing=on
      width="$ICON_ITEM_WIDTH"
      icon.drawing=off
      "label=+$extra_count"
      label.drawing=on
      label.padding_left=2
      label.padding_right=2
    )
  else
    cmd+=(--set "space.$workspace.more"
      drawing=off
      width=0
      padding_left=0
      padding_right=0
      label=""
      label.drawing=off
    )
  fi

  "${cmd[@]}" >/dev/null 2>&1 || true
}

main() {
  command -v aerospace >/dev/null 2>&1 || return 0

  local inputs=()
  if [ "$#" -gt 0 ]; then
    inputs=("$@")
  elif [ -n "$INFO" ]; then
    mapfile -t inputs < <(parse_info_tokens)
  fi

  local targets=()
  if [ "${#inputs[@]}" -gt 0 ]; then
    local arg ws
    for arg in "${inputs[@]}"; do
      ws="$(normalize_ws "$arg")" || continue
      if is_supported_ws "$ws"; then
        case " ${targets[*]} " in *" $ws "*) : ;; *) targets+=("$ws");; esac
      fi
    done
  fi

  local ws_list=()
  if [ "${#targets[@]}" -gt 0 ]; then
    ws_list=("${targets[@]}")
  else
    mapfile -t ws_list < <(workspace_list)
  fi

  local windows

  if [ -n "${WINDOW_SNAPSHOT:-}" ]; then
    windows="$WINDOW_SNAPSHOT"
  else
    local ws_args=()
    for ws in "${ws_list[@]}"; do
      ws_args+=(--workspace "$ws")
    done
    if [ ${#ws_args[@]} -eq 0 ]; then
      ws_args=(--all)
    fi
    windows="$(aerospace list-windows "${ws_args[@]}" --format '%{workspace}%{tab}%{app-name}' 2>/dev/null)" || windows=""
    if [ -z "$windows" ]; then
      return 0
    fi
  fi

  local grouped
  grouped="$(
    awk -F'\t' -v sep="$SEP" -v slots="$VISIBLE_ICON_SLOTS" '
      NR==FNR { order[++n]=$0; want[$0]=1; next }
      {
        ws=$1; app=$2
        sub(/^[[:space:]]+/, "", ws);  sub(/[[:space:]]+$/, "", ws)
        sub(/^[[:space:]]+/, "", app); sub(/[[:space:]]+$/, "", app)
        if (ws=="" || app=="" || !(ws in want)) next

        key = ws SUBSEP app
        if (seen[key]++) next

        cnt[ws]++
        if (lstn[ws] < slots) {
          lstn[ws]++
          if (lst[ws]=="") lst[ws]=app
          else lst[ws]=lst[ws] sep app
        }
      }
      END {
        for (i=1; i<=n; i++) {
          ws=order[i]
          c=(ws in cnt)?cnt[ws]:0
          print ws "\t" c "\t" lst[ws]
        }
      }
    ' <(printf '%s\n' "${ws_list[@]}") <(printf '%s\n' "$windows")
  )"

  local line ws count list
  while IFS=$'\t' read -r ws count list; do
    [ -n "$ws" ] || continue
    update_workspace_icons "$ws" "${count:-0}" "$list"
  done <<<"$grouped"

  return 0
}

main "$@" || true
exit 0
