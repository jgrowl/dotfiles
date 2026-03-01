#!/usr/bin/env bash
# Auto-switch Pulse/PipeWire default sink/source between Arctis and Scarlett.
# - Prefers Arctis when present on host; falls back to Scarlett otherwise.
# - Moves active streams to the chosen default.
# - Accepts flags: --force-arctis | --force-scarlett | --dry-run

set -euo pipefail

# -------- CONFIG (your exact names) ------------------------------------------
ARCTIS_SINK_OVERRIDE="alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game"
ARCTIS_SOURCE_OVERRIDE="alsa_input.usb-SteelSeries_Arctis_Pro_Wireless-00.mono-chat"

SCARLETT_SINK="alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.HiFi__Line2__sink"
SCARLETT_SOURCE="alsa_input.usb-Focusrite_Scarlett_2i4_USB-00.HiFi__Mic1__source"

# Pattern is still useful as a fallback, but we’ll rely on overrides first.
ARCTIS_PATTERN="steelseries\|arctis"
# -----------------------------------------------------------------------------

say() { printf "[audio-defaults] %s\n" "$*" >&2; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_tools() {
  for c in pactl awk grep sed tr hexdump; do
    if ! have_cmd "$c"; then
      echo "Missing required tool: $c" >&2
      exit 1
    fi
  done
}

# Normalize names: strip trailing CR (\r) and other trailing whitespace.
nn() { printf "%s" "$1" | sed 's/\r$//' | sed 's/[[:space:]]*$//'; }

list_sinks()   { pactl list short sinks   | awk '{print $2}'; }
list_sources() { pactl list short sources | awk '{print $2}'; }

exists_sink()   { list_sinks   | grep -x -- "$(nn "$1")" >/dev/null 2>&1; }
exists_source() { list_sources | grep -x -- "$(nn "$1")" >/dev/null 2>&1; }

find_arctis_sink() {
  # Prefer stereo-game; fallback to any arctis sink if needed.
  local s
  s="$(nn "$ARCTIS_SINK_OVERRIDE")"
  if exists_sink "$s"; then echo "$s"; return 0; fi
  list_sinks | grep -iE "$ARCTIS_PATTERN" | head -n1 || true
}

find_arctis_source() {
  local s
  s="$(nn "$ARCTIS_SOURCE_OVERRIDE")"
  if exists_source "$s"; then echo "$s"; return 0; fi
  list_sources | grep -iE "$ARCTIS_PATTERN" | grep -v '\.monitor$' | head -n1 || true
}

set_defaults() {
  local sink_raw="$1" source_raw="$2" dry="$3"
  local sink="$(nn "$sink_raw")"
  local source="$(nn "$source_raw")"

  if [ -n "$sink" ]; then
    say "Setting default sink → $sink"
    if [ "$dry" = "0" ]; then pactl set-default-sink "$sink" || say "WARN: failed to set sink $sink"; fi
  fi
  if [ -n "$source" ]; then
    say "Setting default source → $source"
    if [ "$dry" = "0" ]; then pactl set-default-source "$source" || say "WARN: failed to set source $source"; fi
  fi
}

move_active_streams() {
  local sink_raw="$1" source_raw="$2" dry="$3"
  local sink="$(nn "$sink_raw")"
  local source="$(nn "$source_raw")"

  # Move playback streams to new sink
  local input_ids
  input_ids=$(pactl list short sink-inputs | awk '{print $1}' || true)
  for id in $input_ids; do
    say "Moving sink-input $id → $sink"
    if [ "$dry" = "0" ]; then pactl move-sink-input "$id" "$sink" || say "WARN: failed to move sink-input $id"; fi
  done

  # Move recording streams to new source
  local srcout_ids
  srcout_ids=$(pactl list short source-outputs | awk '{print $1}' || true)
  for id in $srcout_ids; do
    say "Moving source-output $id → $source"
    if [ "$dry" = "0" ]; then pactl move-source-output "$id" "$source" || say "WARN: failed to move source-output $id"; fi
  done
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [--force-arctis | --force-scarlett] [--dry-run]
  --force-arctis    Force Arctis as defaults (if present)
  --force-scarlett  Force Scarlett as defaults
  --dry-run         Show actions without applying
EOF
}

main() {
  require_tools

  local force="auto" dry="0"
  while [ $# -gt 0 ]; do
    case "$1" in
      --force-arctis)   force="arctis" ;;
      --force-scarlett) force="scarlett" ;;
      --dry-run)        dry="1" ;;
      -h|--help)        usage; exit 0 ;;
      *) say "Unknown arg: $1"; usage; exit 1 ;;
    esac
    shift
  done

  local target_sink="" target_source=""

  if [ "$force" = "scarlett" ]; then
    target_sink="$SCARLETT_SINK"
    target_source="$SCARLETT_SOURCE"
    say "Forcing Scarlett."
  elif [ "$force" = "arctis" ]; then
    # Only set if present; otherwise bail gracefully.
    if exists_sink "$ARCTIS_SINK_OVERRIDE" && exists_source "$ARCTIS_SOURCE_OVERRIDE"; then
      target_sink="$ARCTIS_SINK_OVERRIDE"
      target_source="$ARCTIS_SOURCE_OVERRIDE"
      say "Forcing Arctis."
    else
      say "ERROR: Arctis endpoints not present; cannot force."
      exit 2
    fi
  else
    # auto mode: prefer Arctis if present
    local a_sink a_src
    a_sink="$(find_arctis_sink || true)"
    a_src="$(find_arctis_source || true)"
    if [ -n "$a_sink" ] && [ -n "$a_src" ]; then
      say "Arctis detected on host."
      target_sink="$a_sink"
      target_source="$a_src"
    else
      say "Arctis not detected; falling back to Scarlett."
      target_sink="$SCARLETT_SINK"
      target_source="$SCARLETT_SOURCE"
    fi
  fi

  # Safety: verify targets exist
  if ! exists_sink "$target_sink"; then
    say "ERROR: target sink does not exist: $(printf '%s' "$target_sink" | hexdump -C | sed 's/^/[hex] /')"
    exit 3
  fi
  if ! exists_source "$target_source"; then
    say "ERROR: target source does not exist: $(printf '%s' "$target_source" | hexdump -C | sed 's/^/[hex] /')"
    exit 4
  fi

  set_defaults "$target_sink" "$target_source" "$dry"
  move_active_streams "$target_sink" "$target_source" "$dry"
}

main "$@"

