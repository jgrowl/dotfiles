#!/bin/zsh

# Friendly name → camera name substring (must match v4l2-ctl exactly or fuzzily)
typeset -A CAM_PATTERNS
CAM_PATTERNS=(
  office   "Logitech BRIO"
  office2  "Logi Webcam C920e"
  bedroom  "Logitech Webcam C930e"
)

# Resolve camera name to /dev/videoX using fuzzy matching
function resolve_device() {
  local label="$1"
  local pattern="${CAM_PATTERNS[$label]}"
  local dev

  # Search for matching device block using case-insensitive substring
  dev=$(v4l2-ctl --list-devices 2>/dev/null | awk -v pat="$pattern" '
    BEGIN { RS = "" }
    tolower($0) ~ tolower(pat) {
      match($0, /\/dev\/video[0-9]+/, m)
      if (m[0]) {
        print m[0]
        exit
      }
    }
  ')
  echo "$dev"
}

function usage() {
  echo "Usage:"
  echo "  $0 [name|/dev/videoX] [resolution] [--format=FORMAT]"
  echo
  echo "Examples:"
  echo "  $0 office"
  echo "  $0 bedroom 1280x720"
  echo "  $0 /dev/video2 1920x1080 --format=yuyv422"
  echo
  echo "Available friendly names:"
  for name in ${(k)CAM_PATTERNS}; do
    echo "  $name → ${CAM_PATTERNS[$name]}"
  done
  echo
  echo "Detected devices:"
  v4l2-ctl --list-devices 2>/dev/null | awk '
    /^[^\t]/ {printf "\n📷 %s\n", $0}
    /^\t/ {printf "    %s\n", $0}
  '
  echo
  echo "Common supported pixel formats:"
  echo "  mjpeg       # Compressed Motion JPEG"
  echo "  yuyv422     # Raw uncompressed YUYV 4:2:2"
  echo "  h264        # Compressed H.264 (if supported)"
  echo "  nv12        # Planar YUV 4:2:0 (if supported)"
  exit 1
}

# No args? Show help
[[ -z "$1" ]] && usage

# Parse arguments
INPUT="$1"
RESOLUTION="${2:-1920x1080}"  # Default resolution
FORMAT="mjpeg"                # Default format

for arg in "$@"; do
  if [[ "$arg" == --format=* ]]; then
    FORMAT="${arg#--format=}"
  fi
done

# Resolve named device or use raw path
if [[ "$INPUT" == /dev/video* ]]; then
  DEVICE="$INPUT"
else
  DEVICE=$(resolve_device "$INPUT")
fi

[[ -z "$DEVICE" || ! -e "$DEVICE" ]] && echo "❌ Invalid or unresolved device: $INPUT → $DEVICE" && exit 1

echo "🎥 Launching $INPUT ($DEVICE) at $RESOLUTION format=$FORMAT..."

# Launch mpv
exec mpv "av://v4l2:$DEVICE" \
  --demuxer=lavf \
  --demuxer-lavf-o="video_size=$RESOLUTION,input_format=$FORMAT" \
  --untimed \
  --video-sync=desync \
  --vd-lavc-threads=1 \
  --title="$INPUT Camera" \
  --vf="format=yuv422p,eq=contrast=1.05:brightness=0.01:saturation=1.1" \
  --msg-level=ffmpeg=no

