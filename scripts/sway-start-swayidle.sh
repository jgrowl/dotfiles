#!/bin/bash

# Check if running correctly by:
# pgrep -af swayidle

# 30 minutes: 1800
# 1 hour: 3600
# 2 hours: 7200

swayidle -w \
  timeout 3600 'swaylock -f -c 000000' \
  timeout 7200 'swaymsg "output * dpms off"' \
  resume 'swaymsg "output * dpms on"' \
  before-sleep 'swaylock -f -c 000000'

