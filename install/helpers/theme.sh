# Theme asset helpers shared by the installer and runtime commands.

henzos_apply_theme_assets() {
  local theme_dir="$1"
  local henzos_config="${HENZOS_CONFIG:-$HOME/.config/henzos}"

  mkdir -p "$henzos_config/current"
  ln -snf "$theme_dir" "$henzos_config/current/theme"

  if [[ -f "$theme_dir/dunstrc" ]]; then
    mkdir -p "$HOME/.config/dunst"
    cp "$theme_dir/dunstrc" "$HOME/.config/dunst/dunstrc"
  fi

  if [[ -f "$theme_dir/neovim.lua" ]]; then
    mkdir -p "$HOME/.config/nvim/lua/plugins"
    cp "$theme_dir/neovim.lua" "$HOME/.config/nvim/lua/plugins/colorscheme.lua"
  fi

  if [[ -f "$theme_dir/starship.toml" ]]; then
    mkdir -p "$HOME/.config"
    cp "$theme_dir/starship.toml" "$HOME/.config/starship.toml"
  fi
}
