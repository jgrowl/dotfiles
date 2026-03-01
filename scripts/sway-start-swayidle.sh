#!/usr/bin/env bash
# ~/.local/share/chezmoi/scripts/sway-start-swayidle.sh
set -euo pipefail

# ---- Config ----
LOCK_TIME="${LOCK_TIME:-3600}"                         # seconds to auto-lock
LOCK_DPMS_OFF_TIME="${LOCK_DPMS_OFF_TIME:-7200}"       # seconds to DPMS off
#DISABLE_DPMS="${DISABLE_DPMS:-0}"                      # 1 = do not DPMS off/on (no "sleep-ish" display power events)
DISABLE_DPMS="${DISABLE_DPMS:-1}"                      # 1 = do not DPMS off/on (no "sleep-ish" display power events)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sway"
LOG="$STATE_DIR/swayidle.log"
LOCKFILE="${XDG_RUNTIME_DIR:-/run/user/$UID}/swayidle.lock"

mkdir -p "$STATE_DIR"

# ---- Ensure runtime and session env ----
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"

# Prefer existing env; otherwise wait for and pick first live wayland socket
pick_wayland_display() {
  local i=0 max=50
  while (( i < max )); do
    if [[ -n "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]]; then
      return 0
    fi
    for s in "$XDG_RUNTIME_DIR"/wayland-*; do
      [[ -S "$s" ]] || continue
      export WAYLAND_DISPLAY="$(basename "$s")"
      return 0
    done
    sleep 0.2
    ((i++))
  done
  return 1
}

# Wait for responsive Sway IPC (avoids compositor races)
wait_for_ipc() {
  local i=0 max=50
  while (( i < max )); do
    if [[ -z "${SWAYSOCK:-}" ]]; then
      SWAYSOCK="$(ls "$XDG_RUNTIME_DIR"/sway-ipc.*.sock 2>/dev/null | head -n1 || true)"
      export SWAYSOCK
    fi
    if [[ -n "${SWAYSOCK:-}" && -S "$SWAYSOCK" ]]; then
      if swaymsg -t get_version >/dev/null 2>&1; then
        return 0
      fi
    fi
    sleep 0.2
    ((i++))
  done
  return 1
}

# Resolve sockets
pick_wayland_display || { echo "[swayidle] no WAYLAND_DISPLAY" >>"$LOG"; exit 1; }
wait_for_ipc || { echo "[swayidle] sway IPC not ready" >>"$LOG"; exit 1; }

# ---- single instance guard ----
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "[swayidle] already running" >>"$LOG"
  exit 0
fi

# Optional: clean up stale swaylock instances before starting
pkill -x swaylock || true

# ---- build swayidle command ----
CMD=(/usr/bin/swayidle -w)

# Always support locking
CMD+=(lock '/usr/bin/swaylock -f')
CMD+=(timeout "$LOCK_TIME" '/usr/bin/swaylock -f')
CMD+=(before-sleep '/usr/bin/swaylock -f')

# Optional DPMS off/on
if [[ "${DISABLE_DPMS}" != "1" ]]; then
  CMD+=(unlock 'swaymsg -q "output * dpms on"')
  CMD+=(timeout "$LOCK_DPMS_OFF_TIME" 'swaymsg -q "output * dpms off"')
  CMD+=(resume 'swaymsg -q "output * dpms on"')
fi

if [[ "${DEBUG:-0}" == "1" ]]; then
  exec "${CMD[@]}" -d >>"$LOG" 2>&1
else
  exec "${CMD[@]}"
fi




# #!/usr/bin/env bash
# # ~/.local/share/chezmoi/scripts/sway-start-swayidle.sh
# set -euo pipefail
# 
# # ---- Config ----
# LOCK_TIME="${LOCK_TIME:-3600}"                 # seconds to auto-lock
# LOCK_DPMS_OFF_TIME="${LOCK_DPMS_OFF_TIME:-7200}"  # seconds to DPMS off
# STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sway"
# LOG="$STATE_DIR/swayidle.log"
# LOCKFILE="${XDG_RUNTIME_DIR:-/run/user/$UID}/swayidle.lock"
# 
# mkdir -p "$STATE_DIR"
# 
# # ---- Ensure runtime and session env ----
# export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
# export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
# export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"
# 
# # Prefer existing env; otherwise pick first live sockets
# pick_wayland_display() {
#   if [[ -n "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]]; then
#     return 0
#   fi
#   for s in "$XDG_RUNTIME_DIR"/wayland-*; do
#     [[ -S "$s" ]] || continue
#     export WAYLAND_DISPLAY="$(basename "$s")"
#     return 0
#   done
#   return 1
# }
# 
# # Wait for responsive Sway IPC (avoids “Failed to find session” / compositor races)
# wait_for_ipc() {
#   local i=0 max=50
#   while (( i < max )); do
#     # Prefer existing SWAYSOCK; else find one
#     if [[ -z "${SWAYSOCK:-}" ]]; then
#       SWAYSOCK="$(ls "$XDG_RUNTIME_DIR"/sway-ipc.*.sock 2>/dev/null | head -n1 || true)"
#       export SWAYSOCK
#     fi
#     if [[ -n "${SWAYSOCK:-}" && -S "$SWAYSOCK" ]]; then
#       if swaymsg -t get_version >/dev/null 2>&1; then
#         return 0
#       fi
#     fi
#     sleep 0.2
#     ((i++))
#   done
#   return 1
# }
# 
# # Resolve sockets
# pick_wayland_display || { echo "[swayidle] no WAYLAND_DISPLAY" >>"$LOG"; exit 1; }
# wait_for_ipc || { echo "[swayidle] sway IPC not ready" >>"$LOG"; exit 1; }
# 
# # ---- single instance guard ----
# exec 9>"$LOCKFILE"
# if ! flock -n 9; then
#   echo "[swayidle] already running" >>"$LOG"
#   exit 0
# fi
# 
# # Optional: clean up stale swaylock instances before starting
# pkill -x swaylock || true
# 
# # ---- run swayidle ----
# CMD=(/usr/bin/swayidle -w
#   lock '/usr/bin/swaylock -f'
#   unlock 'swaymsg -q "output * dpms on"'
#   timeout "$LOCK_TIME"         '/usr/bin/swaylock -f'
#   timeout "$LOCK_DPMS_OFF_TIME" 'swaymsg -q "output * dpms off"'
#   resume  'swaymsg -q "output * dpms on"'
#   before-sleep '/usr/bin/swaylock -f'
# )
# 
# if [[ "${DEBUG:-0}" == "1" ]]; then
#   exec "${CMD[@]}" -d >>"$LOG" 2>&1
# else
#   exec "${CMD[@]}"
# fi
# 
# 
# 


# # # # #!/bin/bash
# # # # set -euo pipefail
# # # # 
# # # # LOCK_TIME="${LOCK_TIME:-3600}"                # 1h to lock
# # # # LOCK_DPMS_OFF_TIME="${LOCK_DPMS_OFF_TIME:-7200}" # 2h to power off displays
# # # # LOG="${XDG_STATE_HOME:-$HOME/.local/state}/sway/swayidle.log"
# # # # LOCKDIR="$(dirname "$LOG")"
# # # # mkdir -p "$LOCKDIR"
# # # # 
# # # # LOCKFILE="${XDG_RUNTIME_DIR:-/run/user/$UID}/swayidle.lock"
# # # # 
# # # # # Ensure we actually point at the real compositor
# # # # # Prefer existing env if present; otherwise choose the first live socket
# # # # if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
# # # #   for sock in "${XDG_RUNTIME_DIR:-/run/user/$UID}"/wayland-{0..9}; do
# # # #     if [[ -S "$sock" ]]; then
# # # #       export WAYLAND_DISPLAY="$(basename "$sock")"
# # # #       break
# # # #     fi
# # # #   done
# # # # fi
# # # # 
# # # # if [[ -z "${WAYLAND_DISPLAY:-}" || ! -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/${WAYLAND_DISPLAY}" ]]; then
# # # #   echo "[swayidle] No WAYLAND_DISPLAY/socket; exiting" >>"$LOG" 2>&1 || true
# # # #   exit 1
# # # # fi
# # # # 
# # # # # Prevent multiple instances
# # # # exec 9>"$LOCKFILE"
# # # # flock -n 9 || { echo "[swayidle] already running" >>"$LOG" 2>&1; exit 0; }
# # # # 
# # # # DEBUG="${DEBUG:-0}"
# # # # 
# # # # # Common command (lock with -f, quiet swaymsg, symmetric resume/unlock)
# # # # CMD=(/usr/bin/swayidle -w
# # # #   lock '/usr/bin/swaylock -f'
# # # #   unlock 'swaymsg -q "output * dpms on"'
# # # #   timeout "$LOCK_TIME"         '/usr/bin/swaylock -f'
# # # #   timeout "$LOCK_DPMS_OFF_TIME" 'swaymsg -q "output * dpms off"'
# # # #   resume 'swaymsg -q "output * dpms on"'
# # # #   before-sleep '/usr/bin/swaylock -f'
# # # # )
# # # # 
# # # # if [[ "$DEBUG" == "1" ]]; then
# # # #   exec "${CMD[@]}" -d >>"$LOG" 2>&1
# # # # else
# # # #   exec "${CMD[@]}"
# # # # fi
# # # # 





# # # #!/bin/bash
# # # set -euo pipefail
# # # 
# # # LOCK_TIME="${LOCK_TIME:-3600}"          # 1 hour
# # # LOCK_DPMS_OFF_TIME="${LOCK_DPMS_OFF_TIME:-7200}" # 2 hours
# # # LOG="${XDG_STATE_HOME:-$HOME/.local/state}/sway/swayidle.log"
# # # LOCKFILE="${XDG_RUNTIME_DIR:-/run/user/$UID}/swayidle.lock"
# # # 
# # # # Wait for Wayland socket so we don't get "cannot open display"
# # # SOCK_A="${XDG_RUNTIME_DIR:-/run/user/$UID}/wayland-0"
# # # SOCK_B="${XDG_RUNTIME_DIR:-/run/user/$UID}/wayland-1"
# # # if [[ ! -S "$SOCK_A" && ! -S "$SOCK_B" ]]; then
# # #   echo "[swayidle] Wayland socket not found; exiting" >>"$LOG" 2>&1 || true
# # #   exit 1
# # # fi
# # # 
# # # # Prevent multiple instances
# # # exec 9>"$LOCKFILE"
# # # flock -n 9 || { echo "[swayidle] already running" >>"$LOG" 2>&1; exit 0; }
# # # 
# # # # Optional: set DEBUG=1 env var to enable extra logs
# # # DEBUG="${DEBUG:-0}"
# # # if [[ "$DEBUG" == "1" ]]; then
# # #   exec /usr/bin/swayidle -d -w \
# # #     lock '/usr/bin/swaylock' \
# # #     unlock 'swaymsg "output * dpms on"' \
# # #     timeout "$LOCK_TIME" '/usr/bin/swaylock' \
# # #     timeout "$LOCK_DPMS_OFF_TIME" 'swaymsg "output * dpms off"' \
# # #     resume 'swaymsg "output * dpms on"' \
# # #     before-sleep '/usr/bin/swaylock' \
# # #     >>"$LOG" 2>&1
# # # else
# # #   exec /usr/bin/swayidle -w \
# # #     lock '/usr/bin/swaylock' \
# # #     unlock 'swaymsg "output * dpms on"' \
# # #     timeout "$LOCK_TIME" '/usr/bin/swaylock' \
# # #     timeout "$LOCK_DPMS_OFF_TIME" 'swaymsg "output * dpms off"' \
# # #     resume 'swaymsg "output * dpms on"' \
# # #     before-sleep '/usr/bin/swaylock'
# # # fi
# # # 



# #!/bin/bash
# # set -e
# # 
# # # # Check if running correctly by:
# # # # pgrep -af swayidle
# # # 
# # # # 30 minutes: 1800
# # # # 1 hour: 3600
# # # # 2 hours: 7200
# # #
# # #LOCK_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/swaylock/config"
# # LOCK_TIME="3600"
# # LOCK_DPMS_OFF_TIME="7200"
# # 
# # exec /usr/bin/swayidle -w \
# #   lock '/usr/bin/swaylock' \
# #   unlock 'swaymsg "output * dpms on"' \
# #   timeout $LOCK_TIME '/usr/bin/swaylock' \
# #   timeout $LOCK_DPMS_OFF_TIME 'swaymsg "output * dpms off"' \
# #   resume 'swaymsg "output * dpms on"' \
# #   before-sleep '/usr/bin/swaylock'

#exec /usr/bin/swayidle -w \
#  lock /usr/bin/swaylock -C "$LOCK_CFG" \
#  unlock /usr/bin/swaymsg "output * dpms on" \
#  timeout 3600 /usr/bin/swaylock -C "$LOCK_CFG" \
#  timeout 7200 /usr/bin/swaymsg "output * dpms off" \
#  resume /usr/bin/swaymsg "output * dpms on" \
#  before-sleep /usr/bin/swaylock -C "$LOCK_CFG"

#exec /usr/bin/swayidle -w \
#  lock /usr/bin/swaylock \
#  unlock /usr/bin/swaymsg "output * dpms on" \
#  timeout 3600 /usr/bin/swaylock \
#  timeout 7200 /usr/bin/swaymsg "output * dpms off" \
#  resume /usr/bin/swaymsg "output * dpms on" \
#  before-sleep /usr/bin/swaylock


#exec /usr/bin/swayidle -w \
#  lock '/usr/bin/swaylock -C /home/jon/.config/swaylock/config' \
#  unlock 'swaymsg "output * dpms on"' \
#  timeout 3600 '/usr/bin/swaylock -C /home/jon/.config/swaylock/config' \
#  timeout 7200 'swaymsg "output * dpms off"' \
#  resume 'swaymsg "output * dpms on"' \
#  before-sleep '/usr/bin/swaylock -C /home/jon/.config/swaylock/config'
