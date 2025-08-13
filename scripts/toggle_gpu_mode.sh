#!/bin/bash
set -e

GPU_PCI="0000:0f:00.0"
AUDIO_PCI="0000:0f:00.1"

get_current_driver() {
    local pci="$1"
    if [ -e "/sys/bus/pci/devices/$pci/driver" ]; then
        basename "$(readlink "/sys/bus/pci/devices/$pci/driver")"
    else
        echo "unbound"
    fi
}

GPU_DRIVER=$(get_current_driver "$GPU_PCI")

echo "Current driver for GPU: $GPU_DRIVER"

if [ "$GPU_DRIVER" = "vfio-pci" ]; then
    echo "[→] Switching GPU to host (NVIDIA driver)..."

    echo "$GPU_PCI" | sudo tee /sys/bus/pci/devices/$GPU_PCI/driver/unbind || true
    echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/devices/$AUDIO_PCI/driver/unbind || true

    sudo modprobe nvidia nvidia_uvm nvidia_drm nvidia_modeset

    echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/nvidia/bind || true
    echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/drivers/nvidia/bind || true

    echo "[✓] GPU switched to host mode."

elif [ "$GPU_DRIVER" = "nvidia" ]; then
    echo "[→] Switching GPU to VM (VFIO passthrough)..."

    echo "$GPU_PCI" | sudo tee /sys/bus/pci/devices/$GPU_PCI/driver/unbind || true
    echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/devices/$AUDIO_PCI/driver/unbind || true

    sudo modprobe vfio-pci

    echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind || true
    echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind || true

    echo "[✓] GPU switched to passthrough mode."

else
    echo "⚠️ GPU is currently unbound or using unknown driver: $GPU_DRIVER"
    echo "Manually run enable_gpu_for_host.sh or enable_gpu_for_vm.sh"
    exit 1
fi

