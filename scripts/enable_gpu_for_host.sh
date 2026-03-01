#!/bin/bash
set -euo pipefail

GPU_PCI="0000:0f:00.0"
AUDIO_PCI="0000:0f:00.1"

echo "[+] Unbinding from vfio-pci (if bound)..."
for DEV in "$GPU_PCI" "$AUDIO_PCI"; do
  if [ -L /sys/bus/pci/devices/$DEV/driver ] && \
     [ "$(basename "$(readlink -f /sys/bus/pci/devices/$DEV/driver)")" = "vfio-pci" ]; then
    echo "$DEV" | sudo tee /sys/bus/pci/devices/$DEV/driver/unbind
  fi
done

echo "[+] Loading NVIDIA modules..."
sudo modprobe nvidia nvidia_uvm nvidia_drm nvidia_modeset

# bind GPU
CUR_GPU_DRV=""
if [ -L /sys/bus/pci/devices/$GPU_PCI/driver ]; then
  CUR_GPU_DRV=$(basename "$(readlink -f /sys/bus/pci/devices/$GPU_PCI/driver)")
fi

if [ "$CUR_GPU_DRV" != "nvidia" ]; then
  echo "[+] Binding $GPU_PCI to nvidia..."
  echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/nvidia/bind
else
  echo "[✓] GPU already on nvidia."
fi

# bind GPU audio
if [ -d /sys/bus/pci/drivers/snd_hda_intel ]; then
  CUR_AUD_DRV=""
  if [ -L /sys/bus/pci/devices/$AUDIO_PCI/driver ]; then
    CUR_AUD_DRV=$(basename "$(readlink -f /sys/bus/pci/devices/$AUDIO_PCI/driver)")
  fi
  if [ "$CUR_AUD_DRV" != "snd_hda_intel" ]; then
    echo "[+] Binding $AUDIO_PCI to snd_hda_intel..."
    echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/drivers/snd_hda_intel/bind
  else
    echo "[✓] Audio function already on snd_hda_intel."
  fi
else
  echo "[!] snd_hda_intel driver not present; skipping audio bind."
fi

echo "[+] Checking nvidia-smi..."
nvidia-smi || echo "[!] nvidia-smi failed"
echo "[✓] NVIDIA GPU is now available to host."

