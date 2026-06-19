#!/usr/bin/env bash
set -euo pipefail

title="nvtop-monitor"

launch() {
  nohup alacritty --title "$title" -e nvtop >/dev/null 2>&1 &
  disown || true
}

if command -v swaymsg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  IDS="$(
    swaymsg -rt get_tree | jq -r --arg title "$title" '
      .. | objects
      | select((.name? // "") == $title)
      | .id
    '
  )"

  if [[ -n "${IDS}" ]]; then
    while read -r id; do
      [[ -n "${id}" ]] && swaymsg "[con_id=${id}]" kill >/dev/null
    done <<< "${IDS}"
    exit 0
  fi
fi

launch
