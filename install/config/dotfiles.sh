# Deploy henzOS dotfiles
#
# Architecture:
#   Tier 1: ~/.local/share/henzos/default/  (upstream defaults, read-only)
#   Tier 2: ~/.config/                       (copied from config/, user-editable)
#   Tier 3: ~/.config/*/local.conf etc.      (user overrides, sourced last)

henzos_log "Deploying dotfiles..."

# Tier 1: defaults are already in place at HENZOS_PATH/default/
# They are sourced via include/source directives in config files.

# Tier 2: copy config files (only on first run, or missing files)
deploy_config() {
  local src="$1"
  local dest="$2"

  if [[ "$HENZOS_FIRST_RUN" == "true" ]] || [[ ! -e "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -R "$src" "$dest"
  fi
}

# i3
deploy_config "$HENZOS_PATH/config/i3/config"      "$HOME/.config/i3/config"
deploy_config "$HENZOS_PATH/config/i3/local.conf"   "$HOME/.config/i3/local.conf"

# Alacritty
deploy_config "$HENZOS_PATH/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Picom
deploy_config "$HENZOS_PATH/config/picom/picom.conf" "$HOME/.config/picom/picom.conf"

# Rofi
deploy_config "$HENZOS_PATH/config/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

# Polybar
deploy_config "$HENZOS_PATH/config/polybar/config.ini" "$HOME/.config/polybar/config.ini"
deploy_config "$HENZOS_PATH/config/polybar/launch.sh"  "$HOME/.config/polybar/launch.sh"
chmod +x "$HOME/.config/polybar/launch.sh"
mkdir -p "$HOME/.config/polybar/scripts"
for script in "$HENZOS_PATH/config/polybar/scripts/"*.sh; do
  [[ -f "$script" ]] || continue
  deploy_config "$script" "$HOME/.config/polybar/scripts/$(basename "$script")"
  chmod +x "$HOME/.config/polybar/scripts/$(basename "$script")"
done

# dunst
deploy_config "$HENZOS_PATH/config/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"

# Starship
deploy_config "$HENZOS_PATH/config/starship.toml" "$HOME/.config/starship.toml"

# Bashrc
if [[ "$HENZOS_FIRST_RUN" == "true" ]]; then
  # Back up original
  [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$HOME/.bashrc.pre-henzos"
  cp "$HENZOS_PATH/default/bashrc" "$HOME/.bashrc"
fi

# Wallpaper directory
mkdir -p "$HOME/.local/share/henzos/wallpapers"

henzos_ok "Dotfiles deployed"
