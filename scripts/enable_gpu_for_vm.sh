#!/bin/bash
set -e

GPU_PCI="0000:0f:00.0"
AUDIO_PCI="0000:0f:00.1"

echo "[+] Unbinding from nvidia driver..."
echo "$GPU_PCI" | sudo tee /sys/bus/pci/devices/$GPU_PCI/driver/unbind
echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/devices/$AUDIO_PCI/driver/unbind

echo "[+] Binding to vfio-pci..."
sudo modprobe vfio-pci
echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind

echo "[✓] NVIDIA GPU is now ready for passthrough."

