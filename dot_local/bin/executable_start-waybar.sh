#!/usr/bin/env bash
set -euo pipefail

# Make sure SWAYSOCK exists and Sway is answering
for _ in $(seq 1 50); do
  if [ -n "${SWAYSOCK:-}" ] && [ -S "$SWAYSOCK" ] && swaymsg -t get_outputs >/dev/null 2>&1; then
    break
  fi
  # Fallback: try to infer SWAYSOCK if not exported yet
  if [ -z "${SWAYSOCK:-}" ]; then
    c="$(ls "${XDG_RUNTIME_DIR:-/run/user/$UID}"/sway-ipc.*.sock 2>/dev/null | head -n1)"
    [ -n "$c" ] && export SWAYSOCK="$c"
  fi
  sleep 0.2
done

# Extra: ensure there is at least one active output
for _ in $(seq 1 20); do
  if swaymsg -r -t get_outputs | jq -e '.[] | select(.active==true)' >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done

exec /usr/bin/waybar

