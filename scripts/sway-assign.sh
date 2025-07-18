#!/bin/bash

# Get name of the monitor with specific serial
#
# DP-3 = LG Electronics LG ULTRAGEAR (serial: 310NTABB2240)
bottom_left=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.serial=="310NTABB2240") | .name')
if [ -n "$bottom_left" ]; then
    echo "Assigning workspace 1 to $bottom_left"
    swaymsg "workspace 1; move workspace to output $bottom_left"
fi


bottom_right=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.serial=="410NTWG86233") | .name')
if [ -n "$bottom_right" ]; then
    echo "Assigning workspace 2 to $bottom_right"
    swaymsg "workspace 2; move workspace to output $bottom_right"
fi

top_left=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.serial=="E1LMQS012796") | .name')
if [ -n "$top_left" ]; then
    echo "Assigning workspace 3 to $top_left"
    swaymsg "workspace 3; move workspace to output $top_left"
fi

top_right=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.serial=="FBLMQS084061") | .name')
if [ -n "$top_right" ]; then
    echo "Assigning workspace 4 to $top_right"
    swaymsg "workspace 4; move workspace to output $top_right"
fi


