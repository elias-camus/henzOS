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
mkdir -p "$HENZOS_CONFIG"
ln -snf "$THEME_DIR" "$CURRENT_LINK/theme"

# Link theme-specific configs that need to live in specific paths
# dunst reads from ~/.config/dunst/dunstrc — merge theme colors
# Rofi theme is referenced via @theme in config.rasi — no symlink needed
# Alacritty theme is imported via the config — no symlink needed

henzos_ok "Theme: $THEME_NAME"

# Record installed version
echo "1.0.0" > "$HENZOS_CONFIG/version"
