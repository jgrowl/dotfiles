#!/bin/bash
set -eu

outputs_json="$(swaymsg -t get_outputs -r)"

# Bottom right: LG ULTRAGEAR
bottom_right="$(printf '%s\n' "$outputs_json" | jq -r '.[] | select(.serial=="410NTWG86233") | .name' | head -n1)"
if [ -n "$bottom_right" ] && [ "$bottom_right" != "null" ]; then
    echo "Assigning workspace 2 to $bottom_right"
    swaymsg "workspace number 2; move workspace to output $bottom_right"
fi

# Top right: Ancor VS278
top_right="$(printf '%s\n' "$outputs_json" | jq -r '.[] | select(.serial=="FBLMQS084061") | .name' | head -n1)"
if [ -n "$top_right" ] && [ "$top_right" != "null" ]; then
    echo "Assigning workspace 4 to $top_right"
    swaymsg "workspace number 4; move workspace to output $top_right"
fi

# Bottom left: LG ULTRAGEAR
# 508BNGU0N119
#bottom_left="$(printf '%s\n' "$outputs_json" | jq -r '.[] | select(.serial=="310NTABB2240") | .name' | head -n1)"
bottom_left="$(printf '%s\n' "$outputs_json" | jq -r '.[] | select(.serial=="508BNGU0N119") | .name' | head -n1)"
if [ -n "$bottom_left" ] && [ "$bottom_left" != "null" ]; then
    echo "Assigning workspace 1 to $bottom_left"
    swaymsg "workspace number 1; move workspace to output $bottom_left"
fi

# Top left: replacement monitor
top_left="$(printf '%s\n' "$outputs_json" | jq -r '.[] | select(.serial=="407NTEP51236") | .name' | head -n1)"
if [ -n "$top_left" ] && [ "$top_left" != "null" ]; then
    echo "Assigning workspace 3 to $top_left"
    swaymsg "workspace number 3; move workspace to output $top_left"
fi

