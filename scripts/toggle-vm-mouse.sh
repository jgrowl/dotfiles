#!/usr/bin/env bash
set -euo pipefail

VM="win10"
CONN="qemu:///system"
XML="$HOME/.config/libvirt/devices/aerox-mouse.xml"
VID="1038"
PID="183a"

notify() { command -v notify-send >/dev/null && notify-send "VM Mouse" "$1" || true; }

is_vm_running() {
  local st; st="$(virsh -c "$CONN" domstate "$VM" 2>/dev/null || true)"
  [[ "$st" == "running" || "$st" == "in shutdown" ]]
}

is_attached_live() {
  virsh -c "$CONN" dumpxml "$VM" --live 2>/dev/null | grep -q "vendor id='0x$VID'.*product id='0x$PID'"
}

wait_for_host_usb() {
  # Wait up to ~3s for the dongle to re-enumerate to host
  for _ in {1..30}; do
    if lsusb | grep -qi "${VID}:${PID}"; then return 0; fi
    sleep 0.1
  done
  return 1
}

if is_vm_running; then
  if is_attached_live; then
    # Detach from guest
    if virsh -c "$CONN" detach-device "$VM" "$XML" --live; then
      # Give kernel/udev a moment to reclaim it
      if wait_for_host_usb; then
        notify "Detached Aerox from $VM (host has it)."
        exit 0
      else
        notify "Detached from VM, but device didn't reappear on host (replug dongle)."
        exit 1
      fi
    else
      notify "Detach failed."; exit 1
    fi
  else
    # Attach to guest
    if virsh -c "$CONN" attach-device "$VM" "$XML" --live; then
      notify "Attached Aerox to $VM (host mouse disabled)."
    else
      notify "Attach failed."; exit 1
    fi
  fi
else
  # VM not running: toggle persistence for next boot
  if virsh -c "$CONN" dumpxml "$VM" | grep -q "vendor id='0x$VID'.*product id='0x$PID'"; then
    virsh -c "$CONN" detach-device "$VM" "$XML" --config || true
    notify "Removed Aerox from $VM config (will stay on host next boot)."
  else
    virsh -c "$CONN" attach-device "$VM" "$XML" --config || true
    notify "Added Aerox to $VM config (will pass to guest next boot)."
  fi
fi

