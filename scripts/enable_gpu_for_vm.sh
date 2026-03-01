#!/bin/bash
set -euo pipefail

GPU="0000:0f:00.0"
AUDIO="0000:0f:00.1"

GPU_VID="10de"
GPU_DID="2204"
AUD_VID="10de"
AUD_DID="1aef"

echo "[+] Killing processes using NVIDIA..."
sudo fuser -k /dev/nvidia* /dev/dri/* 2>/dev/null || true

echo "[+] Stopping NVIDIA services..."
sudo systemctl stop nvidia-persistenced.service 2>/dev/null || true
sudo systemctl stop nvidia-powerd.service 2>/dev/null || true

echo "[+] Unloading NVIDIA kernel modules..."
sudo modprobe -r nvidia_drm 2>/dev/null || true
sudo modprobe -r nvidia_modeset 2>/dev/null || true
sudo modprobe -r nvidia_uvm 2>/dev/null || true
sudo modprobe -r nvidia 2>/dev/null || true

echo "[+] Loading vfio-pci..."
sudo modprobe vfio-pci

echo "[+] Registering IDs..."
echo "$GPU_VID $GPU_DID" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id
echo "$AUD_VID $AUD_DID" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id

echo "[+] Binding..."
echo "$GPU" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
echo "$AUDIO" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind

echo "[✓] 3090 is now ready for VM passthrough."




# # #!/bin/bash
# # set -euo pipefail
# # 
# # GPU_PCI="0000:0f:00.0"
# # AUDIO_PCI="0000:0f:00.1"
# # 
# # echo "[+] Unbinding GPU/audio from host drivers..."
# # 
# # # Unbind GPU from whatever it is on (nvidia or something else)
# # if [ -L /sys/bus/pci/devices/$GPU_PCI/driver ]; then
# #   CUR_GPU_DRV=$(basename "$(readlink -f /sys/bus/pci/devices/$GPU_PCI/driver)")
# #   echo "    GPU currently on: $CUR_GPU_DRV"
# #   echo "$GPU_PCI" | sudo tee /sys/bus/pci/devices/$GPU_PCI/driver/unbind
# # else
# #   echo "    GPU has no driver bound."
# # fi
# # 
# # # Unbind audio from whatever it is on (snd_hda_intel or nvidia)
# # if [ -L /sys/bus/pci/devices/$AUDIO_PCI/driver ]; then
# #   CUR_AUD_DRV=$(basename "$(readlink -f /sys/bus/pci/devices/$AUDIO_PCI/driver)")
# #   echo "    Audio currently on: $CUR_AUD_DRV"
# #   echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/devices/$AUDIO_PCI/driver/unbind
# # else
# #   echo "    Audio has no driver bound."
# # fi
# # 
# # echo "[+] Ensuring vfio-pci is loaded..."
# # sudo modprobe vfio-pci
# # 
# # echo "[+] Binding GPU to vfio-pci..."
# # echo "$GPU_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
# # 
# # echo "[+] Binding audio to vfio-pci..."
# # echo "$AUDIO_PCI" | sudo tee /sys/bus/pci/drivers/vfio-pci/bind
# # 
# # echo "[✓] GPU + audio are on vfio-pci and ready for passthrough."
# # 
