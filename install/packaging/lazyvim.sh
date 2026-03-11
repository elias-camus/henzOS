# Set up LazyVim for Neovim

NVIM_CONFIG="$HOME/.config/nvim"
NVIM_MANAGED_FLAG="$HENZOS_CONFIG/state/lazyvim-managed"

if [[ -f "$NVIM_MANAGED_FLAG" && -d "$NVIM_CONFIG" ]]; then
  henzos_log "henzOS-managed Neovim config already exists, skipping bootstrap"
else
  henzos_log "Setting up LazyVim..."

  # Back up any existing nvim config
  if [[ -d "$NVIM_CONFIG" ]]; then
    mv "$NVIM_CONFIG" "$NVIM_CONFIG.bak.$(date +%s)"
  fi

  # Deploy henzOS nvim config (LazyVim starter with henzOS customizations)
  cp -R "$HENZOS_PATH/config/nvim" "$NVIM_CONFIG"
  mkdir -p "$(dirname "$NVIM_MANAGED_FLAG")"
  : > "$NVIM_MANAGED_FLAG"

  # First launch to install plugins (headless)
  henzos_log "Installing Neovim plugins (headless)..."
  nvim --headless "+Lazy! sync" +qa >> "$HENZOS_LOG" 2>&1 || true

  henzos_ok "LazyVim ready"
fi
