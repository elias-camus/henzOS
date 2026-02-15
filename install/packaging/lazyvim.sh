# Set up LazyVim for Neovim

NVIM_CONFIG="$HOME/.config/nvim"

if [[ -d "$NVIM_CONFIG/.git" ]]; then
  henzos_log "Neovim config already exists, skipping LazyVim bootstrap"
else
  henzos_log "Setting up LazyVim..."

  # Back up any existing nvim config
  if [[ -d "$NVIM_CONFIG" ]]; then
    mv "$NVIM_CONFIG" "$NVIM_CONFIG.bak.$(date +%s)"
  fi

  # Deploy henzOS nvim config (LazyVim starter with henzOS customizations)
  cp -R "$HENZOS_PATH/config/nvim" "$NVIM_CONFIG"

  # First launch to install plugins (headless)
  henzos_log "Installing Neovim plugins (headless)..."
  nvim --headless "+Lazy! sync" +qa >> "$HENZOS_LOG" 2>&1 || true

  henzos_ok "LazyVim ready"
fi
