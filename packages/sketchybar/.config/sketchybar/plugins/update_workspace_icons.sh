#!/usr/bin/env bash
# 各ワークスペースにアプリアイコンをまとめて描画する

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

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

# Lock (portable): mkdir is atomic on POSIX
LOCK_DIR="${LOCK_DIR:-/tmp/skbar_wsicons.lock}"
LOCK_RETRY_INTERVAL="${LOCK_RETRY_INTERVAL:-0.05}"
LOCK_MAX_RETRY="${LOCK_MAX_RETRY:-40}"
LOCK_STALE_SECS="${LOCK_STALE_SECS:-8}"

lock_age_seconds() {
  local now mtime
  now=$(date +%s)
  mtime=$(stat -f %m "$LOCK_DIR" 2>/dev/null || stat -c %Y "$LOCK_DIR" 2>/dev/null || echo 0)
  [ "$mtime" -gt 0 ] || return 1
  echo $((now - mtime))
}

cleanup_lock() {
  [ -d "$LOCK_DIR" ] && rmdir "$LOCK_DIR" >/dev/null 2>&1
}

acquire_lock() {
  local attempt=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    if [ -d "$LOCK_DIR" ]; then
      local age
      age=$(lock_age_seconds || echo 0)
      if [ "$age" -gt "$LOCK_STALE_SECS" ]; then
        rmdir "$LOCK_DIR" >/dev/null 2>&1 || true
      fi
    fi
    attempt=$((attempt + 1))
    if [ "$attempt" -ge "$LOCK_MAX_RETRY" ]; then
      return 1
    fi
    sleep "$LOCK_RETRY_INTERVAL"
  done
  return 0
}

if ! acquire_lock; then
  exit 0
fi
trap cleanup_lock EXIT INT TERM

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

numeric_workspaces() {
  seq "$MIN_WORKSPACE" "$MAX_WORKSPACE" 2>/dev/null \
    || jot - "$MIN_WORKSPACE" "$MAX_WORKSPACE" 2>/dev/null \
    || echo "$MIN_WORKSPACE $MAX_WORKSPACE" | awk '{for(i=$1;i<=$2;i++)print i}'
}

workspace_list() {
  local w
  numeric_workspaces
  for w in $EXTRA_WORKSPACES; do
    printf '%s\n' "$w"
  done
}

collect_windows() {
  local args=()
  if [ "$#" -gt 0 ]; then
    local raw w
    for raw in "$@"; do
      w="$(normalize_ws "$raw")" || continue
      is_supported_ws "$w" || continue
      args+=(--workspace "$w")
    done
  fi
  [ "${#args[@]}" -gt 0 ] || args=(--all)

  if ! command -v aerospace >/dev/null 2>&1; then
    return 1
  fi

  aerospace list-windows "${args[@]}" --format '%{workspace}|%{app-name}' 2>/dev/null || return 1
}

apps_for_ws() {
  awk -F'|' -v id="$1" '
    {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1);
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
      if ($1 == id) print $2;
    }
  ' | awk '!seen[$0]++'
}

escape_app_for_sketchybar() {
  printf '%s' "$1" | sed -e 's/[\\"]/\\&/g'
}

build_and_apply_updates() {
  local ws="$1"
  local uniq apps total extra
  uniq="$(cat)"
  total=$(printf '%s\n' "$uniq" | grep -c . || true)
  if [ "$total" -gt "$VISIBLE_ICON_SLOTS" ]; then
    extra=$((total - VISIBLE_ICON_SLOTS))
  else
    extra=0
  fi
  apps="$(printf '%s\n' "$uniq" | sed -n "1,${VISIBLE_ICON_SLOTS}p")"

  local cmd=(sketchybar
    --set "space.$ws" drawing=on icon="$ws" icon.drawing=on icon.background.drawing=off icon.background.image="" label="" label.drawing=off
  )

  local slot=1
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    local app esc item="space.$ws.icon$slot"
    app="$(trim "$line")"
    esc="$(escape_app_for_sketchybar "$app")"
    if [ -n "$app" ]; then
      cmd+=( --set "$item"
        drawing=on
        width="$ICON_ITEM_WIDTH"
        icon=" "
        icon.drawing=on
        icon.background.image="app.$esc"
        icon.background.drawing=on
        icon.background.image.scale="$ICON_IMAGE_SCALE"
        icon.background.corner_radius=3
        icon.background.height="$ICON_HEIGHT"
        icon.background.y_offset=0
        icon.padding_left=2
        icon.padding_right=2
        icon.width="$ICON_WIDTH"
        label=""
        label.drawing=off
      )
    else
      cmd+=( --set "$item"
        drawing=off
        width=0
        padding_left=0
        padding_right=0
        icon=""
        icon.drawing=off
        icon.background.image=""
        icon.background.drawing=off
        icon.background.height="$ICON_HEIGHT"
        icon.background.y_offset=0
        label=""
        label.drawing=off
      )
    fi
    slot=$((slot+1))
  done <<EOF
$apps
EOF

  while [ "$slot" -le "$VISIBLE_ICON_SLOTS" ]; do
    local item="space.$ws.icon$slot"
    cmd+=( --set "$item"
      drawing=off
      width=0
      padding_left=0
      padding_right=0
      icon.drawing=off
      icon.background.drawing=off
      icon=""
      label=""
      label.drawing=off
    )
    slot=$((slot+1))
  done

  if [ "$extra" -gt 0 ]; then
    cmd+=( --set "space.$ws.more"
      drawing=on
      width="$ICON_ITEM_WIDTH"
      icon.drawing=off
      label="+$extra"
      label.drawing=on
      label.padding_left=2
      label.padding_right=2
    )
  else
    cmd+=( --set "space.$ws.more"
      drawing=off
      width=0
      padding_left=0
      padding_right=0
      label=""
      label.drawing=off
    )
  fi

  "${cmd[@]}"
}

refresh_all_or_subset() {
  local snapshot
  if ! snapshot="$(collect_windows "$@")"; then
    return 1
  fi

  if [ "$#" -gt 0 ]; then
    local raw w
    for raw in "$@"; do
      w="$(normalize_ws "$raw")" || continue
      is_supported_ws "$w" || continue
      printf '%s\n' "$snapshot" | apps_for_ws "$w" | build_and_apply_updates "$w"
    done
  else
    local w
    for w in $(workspace_list); do
      printf '%s\n' "$snapshot" | apps_for_ws "$w" | build_and_apply_updates "$w"
    done
  fi
}

if [ -n "$1" ]; then
  refresh_all_or_subset "$1"
elif [ -n "$INFO" ]; then
  refresh_all_or_subset "$INFO"
else
  refresh_all_or_subset
fi
