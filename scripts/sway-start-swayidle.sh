#!/bin/bash

# Check if running correctly by:
# pgrep -af swayidle

# 30 minutes: 1800

swayidle -w \
  timeout 900 'swaylock -f -c 000000' \
  timeout 1800 'swaymsg "output * dpms off"' \
  resume 'swaymsg "output * dpms on"' \
  before-sleep 'swaylock -f -c 000000'

