#!/bin/bash
set -e

GPU_PCI="0000:0f:00.0"
AUDIO_PCI="0000:0f:00.1"

echo "[+] Unbinding from vfio-pci..."
echo "$GPU_PCI" | sudo tee /sys/bus/pci/devices/$GPU_PCI/driver/unbind || true
echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/devices/$AUDIO_PCI/driver/unbind || true

echo "[+] Loading NVIDIA kernel modules..."
sudo modprobe nvidia nvidia_uvm nvidia_drm nvidia_modeset

# Only bind if not already using nvidia
CURRENT_DRIVER=$(basename "$(readlink /sys/bus/pci/devices/$GPU_PCI/driver)")
if [ "$CURRENT_DRIVER" != "nvidia" ]; then
  echo "[+] Binding GPU to nvidia driver..."
  echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/nvidia/bind
else
  echo "[✓] GPU is already bound to nvidia."
fi

echo "[✓] NVIDIA GPU is now available to host!"
nvidia-smi || echo "⚠️ nvidia-smi failed — check driver install or logs"

