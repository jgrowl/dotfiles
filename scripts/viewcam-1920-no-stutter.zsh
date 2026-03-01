#!/bin/zsh

# Map camera names to device paths
declare -A CAMERAS
CAMERAS=(
  [office]="/dev/video2"
  [bedroom]="/dev/video0"
)

# Check for camera name
if [[ -z "$1" ]]; then
  echo "Usage: $0 [office|bedroom]"
  exit 1
fi

DEVICE="${CAMERAS[$1]}"
if [[ -z "$DEVICE" ]]; then
  echo "❌ Unknown camera name: $1"
  exit 1
fi

echo "🎥 Launching $1 camera at 1920x1080 MJPEG..."

exec mpv "av://v4l2:${DEVICE}" \
  --demuxer=lavf \
  --demuxer-lavf-o=video_size=1920x1080,input_format=mjpeg \
  --untimed \
  --video-sync=desync \
  --vd-lavc-threads=1 \
  --title="$1 Camera"

