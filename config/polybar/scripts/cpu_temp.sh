#!/usr/bin/env bash
set -euo pipefail

cpu_hwmon=""
for h in /sys/class/hwmon/hwmon*; do
  name=$(cat "$h/name" 2>/dev/null || true)
  case "$name" in
    k10temp|coretemp)
      cpu_hwmon="$h"
      break
      ;;
  esac
done

if [[ -n "$cpu_hwmon" && -f "$cpu_hwmon/temp1_input" ]]; then
  temp=$(awk '{printf "%.0f", $1/1000}' "$cpu_hwmon/temp1_input")
  echo "TMP ${temp}C"
fi
