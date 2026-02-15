#!/usr/bin/env bash
set -euo pipefail

polybar-msg cmd quit >/dev/null 2>&1 || true
while pgrep -u "$(id -u)" -x polybar >/dev/null; do
  sleep 0.2
done

polybar main >>/tmp/polybar.log 2>&1 &
