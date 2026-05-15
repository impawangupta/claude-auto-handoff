#!/usr/bin/env bash

# claude-auto-handoff: context-monitor.sh
# Stop hook - runs after every Claude response.
# Tracks session turn count and signals Claude when context is getting long.

set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────

PLUGIN_DIR="${HOME}/.claude/workspace/plugins/handoff"
CONFIG_GLOBAL="${PLUGIN_DIR}/config.json"
CONFIG_LOCAL="${PWD}/.claude-auto-handoff.json"
SESSION_DIR="${PLUGIN_DIR}/sessions"

# ── Config ────────────────────────────────────────────────────────────────────

DEFAULT_THRESHOLD=25
DEFAULT_WARN_AT=21
DEFAULT_REMIND_EVERY=3

THRESHOLD=$DEFAULT_THRESHOLD
WARN_AT=$DEFAULT_WARN_AT
REMIND_EVERY=$DEFAULT_REMIND_EVERY

load_value() {
  local file="$1" key="$2" default="$3"
  if command -v jq &>/dev/null && [ -f "$file" ]; then
    local val
    val=$(jq -r ".${key} // empty" "$file" 2>/dev/null)
    echo "${val:-$default}"
  else
    echo "$default"
  fi
}

if [ -f "$CONFIG_GLOBAL" ]; then
  THRESHOLD=$(load_value "$CONFIG_GLOBAL" "threshold"    $DEFAULT_THRESHOLD)
  WARN_AT=$(load_value   "$CONFIG_GLOBAL" "warn_at"      $DEFAULT_WARN_AT)
  REMIND_EVERY=$(load_value "$CONFIG_GLOBAL" "remind_every" $DEFAULT_REMIND_EVERY)
fi

# Project-level config overrides global
if [ -f "$CONFIG_LOCAL" ]; then
  THRESHOLD=$(load_value "$CONFIG_LOCAL" "threshold"    $THRESHOLD)
  WARN_AT=$(load_value   "$CONFIG_LOCAL" "warn_at"      $WARN_AT)
  REMIND_EVERY=$(load_value "$CONFIG_LOCAL" "remind_every" $REMIND_EVERY)
fi

# ── Session tracking ──────────────────────────────────────────────────────────

mkdir -p "$SESSION_DIR"

# Session key: parent PID (stable for one claude invocation) + working dir
DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
SESSION_FILE="${SESSION_DIR}/${PPID}${DIR_SAFE}"

TURNS=0
if [ -f "$SESSION_FILE" ]; then
  TURNS=$(cat "$SESSION_FILE" 2>/dev/null || echo 0)
fi
TURNS=$((TURNS + 1))
echo "$TURNS" > "$SESSION_FILE"

# ── Cleanup stale sessions (older than 7 days) ────────────────────────────────

find "$SESSION_DIR" -type f -mtime +7 -delete 2>/dev/null || true

# ── Signals ───────────────────────────────────────────────────────────────────

if [ "$TURNS" -eq "$WARN_AT" ]; then
  echo "[CONTEXT MONITOR] Turn ${TURNS}: This session is getting on the longer side. Worth keeping in mind — a handoff may be useful soon."

elif [ "$TURNS" -ge "$THRESHOLD" ]; then
  TURNS_OVER=$((TURNS - THRESHOLD))
  if [ "$TURNS_OVER" -eq 0 ] || [ $(( TURNS_OVER % REMIND_EVERY )) -eq 0 ]; then
    echo "[CONTEXT MONITOR] Turn ${TURNS} (threshold: ${THRESHOLD}): For optimal response quality, please offer the user a handoff to a fresh Claude session."
  fi
fi

exit 0
