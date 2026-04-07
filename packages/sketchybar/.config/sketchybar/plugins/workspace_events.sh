#!/usr/bin/env bash
# ワークスペース・アプリ監視のイベントエントリーポイント

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
UPDATE_SCRIPT="$CONFIG_DIR/plugins/update_single_workspace.sh"

MIN_INTERVAL_DEFAULT_NS=300000000   # 0.3s
POLL_INTERVAL_DEFAULT=0.7
STATE_FILE="${POLL_STATE_FILE:-/tmp/sketchybar_ws_state.tsv}"
SECOND_PASS_DELAY="${SECOND_PASS_DELAY:-0.35}"

EVENT_LOCK_DIR="${WS_EVENT_LOCK_DIR:-/tmp/sketchybar_ws_event.lock}"
EVENT_PENDING_FILE="${WS_EVENT_PENDING_FILE:-/tmp/sketchybar_ws_event.pending}"
EVENT_LOCK_STALE_SECS="${WS_EVENT_LOCK_STALE_SECS:-3}"
EVENT_DEBOUNCE_DELAY="${WS_EVENT_DEBOUNCE_DELAY:-0.03}"
EVENT_MAX_RERUNS="${WS_EVENT_MAX_RERUNS:-3}"

lock_age_seconds() {
  local now mtime
  now=$(date +%s)
  mtime=$(stat -f %m "$EVENT_LOCK_DIR" 2>/dev/null || stat -c %Y "$EVENT_LOCK_DIR" 2>/dev/null || echo 0)
  [ "$mtime" -gt 0 ] || return 1
  echo $((now - mtime))
}

cleanup_event_lock() {
  [ -d "$EVENT_LOCK_DIR" ] && rmdir "$EVENT_LOCK_DIR" >/dev/null 2>&1
}

acquire_event_lock() {
  if mkdir "$EVENT_LOCK_DIR" 2>/dev/null; then
    return 0
  fi

  if [ -d "$EVENT_LOCK_DIR" ]; then
    local age
    age=$(lock_age_seconds || echo 0)
    if [ "$age" -gt "$EVENT_LOCK_STALE_SECS" ]; then
      rmdir "$EVENT_LOCK_DIR" >/dev/null 2>&1 || true
      if mkdir "$EVENT_LOCK_DIR" 2>/dev/null; then
        return 0
      fi
    fi
  fi

  printf '1' > "$EVENT_PENDING_FILE" 2>/dev/null || true
  return 1
}

# スロットル: イベントは優先、ポーリングのみ間引く
POLL_INTERVAL="${WORKSPACE_POLL_SECS:-$POLL_INTERVAL_DEFAULT}"
POLL_LOCK="${POLL_LOCK:-/tmp/sketchybar_ws_poll.lock}"

force_event=0
case "${SENDER:-}" in
  front_app_switched|aerospace_workspace_change)
    force_event=1 ;;
esac

if [ "$force_event" -ne 1 ]; then
  NOW_TS=$(date +%s%N)
  if [ -f "$POLL_LOCK" ]; then
    LAST_TS=$(cat "$POLL_LOCK" 2>/dev/null || echo 0)
    THRESHOLD_NS=$(awk -v v="$POLL_INTERVAL" 'BEGIN{printf "%.0f", v*1000000000}')
    DELTA=$((NOW_TS - LAST_TS))
    if [ "$DELTA" -lt "$THRESHOLD_NS" ] && [ "$DELTA" -lt "$MIN_INTERVAL_DEFAULT_NS" ]; then
      exit 0
    fi
  fi
  printf '%s' "$NOW_TS" > "$POLL_LOCK" 2>/dev/null || true
fi

if [ ! -x "$UPDATE_SCRIPT" ]; then
  exit 1
fi

AEROSPACE_BIN="$(type -P aerospace 2>/dev/null || true)"
if [ -z "$AEROSPACE_BIN" ]; then
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  AEROSPACE_BIN="$(type -P aerospace 2>/dev/null || true)"
fi
if [ -z "$AEROSPACE_BIN" ]; then
  exit 1
fi

capture_snapshot() {
  aerospace list-windows --all --format '%{workspace}%{tab}%{app-name}' 2>/dev/null || true
}

MIN_WORKSPACE_NUM=${MIN_WORKSPACE:-1}
MAX_WORKSPACE_NUM=${WORKSPACE_RANGE_MAX:-${MAX_WORKSPACE:-9}}
EXTRA_WORKSPACES="${EXTRA_WORKSPACES:-}"

trim() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

numeric_workspaces() {
  seq "$MIN_WORKSPACE_NUM" "$MAX_WORKSPACE_NUM" 2>/dev/null \
    || jot - "$MIN_WORKSPACE_NUM" "$MAX_WORKSPACE_NUM" 2>/dev/null \
    || echo "$MIN_WORKSPACE_NUM $MAX_WORKSPACE_NUM" | awk '{for(i=$1;i<=$2;i++)print i}'
}

workspace_list() {
  local w
  numeric_workspaces
  for w in $EXTRA_WORKSPACES; do
    printf '%s\n' "$w"
  done
}

is_supported_ws() {
  local ws="$1"
  case "$ws" in
    '' ) return 1 ;;
    *[!0-9]* ) ;;
    * )
      [ "$ws" -ge "$MIN_WORKSPACE_NUM" ] && [ "$ws" -le "$MAX_WORKSPACE_NUM" ]
      return $? ;;
  esac

  local extra
  for extra in $EXTRA_WORKSPACES; do
    [ "$ws" = "$extra" ] && return 0
  done
  return 1
}

parse_info_targets() {
  local tok
  for tok in $(printf '%s' "${INFO:-}" | tr -c '[:alnum:]' ' '); do
    is_supported_ws "$tok" && printf '%s\n' "$tok"
  done
}

snapshot_workspaces() {
  printf '%s\n' "$WINDOW_SNAPSHOT" | awk -F'\t' '
    {
      ws=$1
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", ws)
      if (ws=="" || seen[ws]++) next
      order[++n]=ws
    }
    END { for(i=1;i<=n;i++) print order[i] }
  '
}

build_state_lines() {
  awk -F'\t' -v sep="\034" '
    NR==FNR { order[++n]=$1; want[$1]=1; next }
    {
      ws=$1; app=$2
      sub(/^[[:space:]]+|[[:space:]]+$/, "", ws)
      sub(/^[[:space:]]+|[[:space:]]+$/, "", app)
      if (ws=="" || !(ws in want)) next
      key=ws SUBSEP app
      if (seen[key]++) next
      if (apps[ws]=="") apps[ws]=app; else apps[ws]=apps[ws] sep app
    }
    END {
      for (i=1; i<=n; i++) {
        ws=order[i]
        print ws "\t" apps[ws]
      }
    }
  ' <(workspace_list) <(printf '%s\n' "$WINDOW_SNAPSHOT")
}

run_once() {
  WINDOW_SNAPSHOT="$(capture_snapshot)"
  if [ -z "$WINDOW_SNAPSHOT" ]; then
    sleep 0.15
    WINDOW_SNAPSHOT="$(capture_snapshot)"
  fi
  export WINDOW_SNAPSHOT

  OLD_STATE="$(cat "$STATE_FILE" 2>/dev/null || true)"
  NEW_STATE="$(build_state_lines)"

  collect_changed_ws() {
    local changed_ws=()
    while IFS=$'\t' read -r ws apps; do
      [ -n "$ws" ] || continue
      old_line=$(printf '%s\n' "$OLD_STATE" | awk -F'\t' -v w="$ws" '$1==w{print $0; exit}')
      new_line="$ws\t$apps"
      if [ "$old_line" != "$new_line" ]; then
        changed_ws+=("$ws")
      fi
    done <<<"$NEW_STATE"
    printf '%s\n' "${changed_ws[@]}" | tr ' ' '\n' | sed '/^$/d'
  }

  mapfile -t diff_targets < <(collect_changed_ws)
  printf '%s\n' "$NEW_STATE" > "$STATE_FILE" 2>/dev/null || true

  if [ ${#diff_targets[@]} -eq 0 ] && [ "$force_event" -ne 1 ]; then
    return 0
  fi

  targets=()
  if [ ${#diff_targets[@]} -gt 0 ]; then
    targets=("${diff_targets[@]}")
  elif [ -n "${INFO:-}" ]; then
    mapfile -t targets < <(parse_info_targets)
  fi

  if [ ${#targets[@]} -eq 0 ]; then
    case "${SENDER:-}" in
      front_app_switched)
        mapfile -t targets < <(snapshot_workspaces | while read -r ws; do is_supported_ws "$ws" && printf '%s\n' "$ws"; done)
        ;;
      *)
        focused="$(aerospace list-workspaces --focused --format '%{workspace}' 2>/dev/null | tr -d '[:space:]')"
        if [ -n "$focused" ] && is_supported_ws "$focused"; then
          targets=("$focused")
        fi
        ;;
    esac
  fi

  if [ ${#targets[@]} -eq 0 ]; then
    SENDER="${SENDER:-poll}" "$UPDATE_SCRIPT"
  else
    SENDER="${SENDER:-poll}" "$UPDATE_SCRIPT" "${targets[@]}"
  fi

  if [ "$force_event" -eq 1 ]; then
    if [ ${#targets[@]} -gt 0 ]; then
      ( sleep "$SECOND_PASS_DELAY"; SENDER="delayed" "$UPDATE_SCRIPT" "${targets[@]}" ) &
    else
      ( sleep "$SECOND_PASS_DELAY"; SENDER="delayed" "$UPDATE_SCRIPT" ) &
    fi
  fi

  return 0
}

if ! acquire_event_lock; then
  exit 0
fi
trap cleanup_event_lock EXIT INT TERM

reruns=0
while [ "$reruns" -lt "$EVENT_MAX_RERUNS" ]; do
  reruns=$((reruns + 1))
  if [ -n "$EVENT_DEBOUNCE_DELAY" ] && [ "$EVENT_DEBOUNCE_DELAY" != "0" ]; then
    sleep "$EVENT_DEBOUNCE_DELAY"
  fi

  run_once || true

  if [ -f "$EVENT_PENDING_FILE" ]; then
    rm -f "$EVENT_PENDING_FILE" 2>/dev/null || true
    continue
  fi
  break
done

exit 0
