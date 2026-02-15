# Logging helpers for henzOS installer

henzos_log() {
  echo "[henzOS] $*" | tee -a "$HENZOS_LOG"
}

henzos_step() {
  echo ""
  echo "=> $*"
  echo "---[ $* ]---" >> "$HENZOS_LOG"
}

henzos_ok() {
  echo "   [OK] $*"
}

henzos_warn() {
  echo "   [WARN] $*" >&2
}

henzos_error() {
  echo "   [ERROR] $*" >&2
  echo "[ERROR] $*" >> "$HENZOS_LOG"
}

# Run a command, logging output to file but showing only errors on terminal
run_logged() {
  if ! "$@" >> "$HENZOS_LOG" 2>&1; then
    henzos_error "Command failed: $*"
    henzos_error "Check $HENZOS_LOG for details"
    return 1
  fi
}
