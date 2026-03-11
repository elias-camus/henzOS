# Set up henzOS theme system

henzos_log "Setting up theme..."

THEME_NAME="${HENZOS_THEME:-emerald}"
THEME_DIR="$HENZOS_PATH/themes/$THEME_NAME"
CURRENT_LINK="$HENZOS_CONFIG/current"

if [[ ! -d "$THEME_DIR" ]]; then
  henzos_error "Theme '$THEME_NAME' not found in $HENZOS_PATH/themes/"
  exit 1
fi

# Create the current theme symlink
mkdir -p "$CURRENT_LINK"
henzos_apply_theme_assets "$THEME_DIR"

henzos_ok "Theme: $THEME_NAME"

# Record installed version
echo "1.0.0" > "$HENZOS_CONFIG/version"
