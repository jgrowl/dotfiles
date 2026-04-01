#!/usr/bin/env bash

set -u

GPU_INDEX=0
TOP_N=4

trim() {
  printf '%s' "$1" | xargs
}

escape_json() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

gpu_line="$(nvidia-smi \
  --id="$GPU_INDEX" \
  --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu,clocks.current.graphics,power.draw \
  --format=csv,noheader,nounits 2>/dev/null | head -n1)"

if [ -z "$gpu_line" ]; then
  printf '{"text":"N/A","tooltip":"No data from nvidia-smi","class":"gpu","percentage":0}\n'
  exit 0
fi

IFS=',' read -r util mem_used mem_total temp clock power <<EOF
$gpu_line
EOF

util="$(trim "$util")"
mem_used="$(trim "$mem_used")"
mem_total="$(trim "$mem_total")"
temp="$(trim "$temp")"
clock="$(trim "$clock")"
power="$(trim "$power")"

if [ -n "$mem_total" ] && [ "$mem_total" -gt 0 ] 2>/dev/null; then
  mem_pct=$(( mem_used * 100 / mem_total ))
else
  mem_pct=0
fi

proc_lines="$(
  nvidia-smi \
    --id="$GPU_INDEX" \
    --query-compute-apps=pid,process_name,used_gpu_memory \
    --format=csv,noheader,nounits 2>/dev/null \
  | awk -F',' '
      NF >= 3 {
        pid=$1; name=$2; mem=$3;
        gsub(/^[ \t]+|[ \t]+$/, "", pid);
        gsub(/^[ \t]+|[ \t]+$/, "", name);
        gsub(/^[ \t]+|[ \t]+$/, "", mem);
        if (pid != "" && mem != "" && mem != "[Not Found]") {
          print mem "|" pid "|" name;
        }
      }
    ' \
  | sort -t'|' -k1,1nr \
  | head -n "$TOP_N"
)"

pmon_lines="$(
  nvidia-smi pmon -i "$GPU_INDEX" -c 1 -s um 2>/dev/null \
  | awk '
      $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9-]+$/ {
        pid=$2; sm=$4; mem=$5; enc=$6; dec=$7;
        if (pid != "-" && pid != "0") {
          print pid "|" sm "|" mem "|" enc "|" dec;
        }
      }
    '
)"

tooltip="GPU Usage: ${util}%\rVRAM: ${mem_used} / ${mem_total} MiB (${mem_pct}%)\rTemp: ${temp} degC\rClock: ${clock} MHz\rPower: ${power} W"

if [ -n "$proc_lines" ]; then
  tooltip="${tooltip}\r--- Top GPU Processes ---"
  while IFS='|' read -r used_mem pid pname; do
    [ -z "$pid" ] && continue

    sm="?"
    pmem="?"
    enc="?"
    dec="?"

    if [ -n "$pmon_lines" ]; then
      match="$(printf '%s\n' "$pmon_lines" | awk -F'|' -v target="$pid" '$1 == target { print; exit }')"
      if [ -n "$match" ]; then
        IFS='|' read -r _ sm pmem enc dec <<EOF
$match
EOF
      fi
    fi

    short_name="$(basename "$pname")"
    tooltip="${tooltip}\rPID ${pid} ${short_name}: ${used_mem} MiB | SM ${sm}% | MEM ${pmem}%"
  done <<EOF
$proc_lines
EOF
else
  tooltip="${tooltip}\rNo active compute-app processes found"
fi

tooltip_json="$(printf '%s' "$tooltip" | escape_json)"

printf '{"text":"%s%%","tooltip":"%s","class":"gpu","percentage":%s}\n' \
  "$util" "$tooltip_json" "$util"
