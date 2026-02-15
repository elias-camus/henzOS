# Detect fresh install vs upgrade

if [[ -f "$HENZOS_CONFIG/version" ]]; then
  HENZOS_PREV_VERSION=$(cat "$HENZOS_CONFIG/version")
  export HENZOS_FIRST_RUN=false
  henzos_ok "Upgrading from $HENZOS_PREV_VERSION"

  # Run pending migrations
  if [[ -d "$HENZOS_PATH/migrations" ]]; then
    for migration in "$HENZOS_PATH/migrations"/*.sh; do
      [[ -f "$migration" ]] || continue
      migration_id=$(basename "$migration" .sh)
      if ! grep -qx "$migration_id" "$HENZOS_CONFIG/migrations.log" 2>/dev/null; then
        henzos_log "Running migration: $migration_id"
        source "$migration"
        echo "$migration_id" >> "$HENZOS_CONFIG/migrations.log"
      fi
    done
  fi
else
  export HENZOS_FIRST_RUN=true
  mkdir -p "$HENZOS_CONFIG"
  henzos_ok "Fresh install"
fi
