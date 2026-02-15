#!/usr/bin/env bash
set -euo pipefail

# NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
  line=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)
  if [[ -n "$line" ]]; then
    util=$(echo "$line" | awk -F',' '{gsub(/ /,"",$1); print $1}')
    temp=$(echo "$line" | awk -F',' '{gsub(/ /,"",$2); print $2}')
    echo "GPU ${util}% ${temp}C"
    exit 0
  fi
fi

# AMD
util=""
for f in /sys/class/drm/card*/device/gpu_busy_percent; do
  if [[ -f "$f" ]]; then
    util=$(cat "$f" 2>/dev/null || true)
    break
  fi
done

temp=""
for h in /sys/class/hwmon/hwmon*; do
  name=$(cat "$h/name" 2>/dev/null || true)
  if [[ "$name" == "amdgpu" && -f "$h/temp1_input" ]]; then
    temp=$(awk '{printf "%.0f", $1/1000}' "$h/temp1_input")
    break
  fi
done

if [[ -n "$util" || -n "$temp" ]]; then
  out="GPU"
  [[ -n "$util" ]] && out+=" ${util}%"
  [[ -n "$temp" ]] && out+=" ${temp}C"
  echo "$out"
fi
