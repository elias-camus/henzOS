# Configure apt for non-interactive install

export DEBIAN_FRONTEND=noninteractive

henzos_log "Updating package lists..."
run_logged sudo apt-get update -qq

# Ensure add-apt-repository is available
run_logged sudo apt-get install -y -qq software-properties-common

# Add PPAs if needed (e.g., for latest Neovim)
if ! apt-cache policy neovim 2>/dev/null | grep -q "0.10\|0.11"; then
  henzos_log "Adding Neovim PPA..."
  run_logged sudo add-apt-repository -y ppa:neovim-ppa/unstable
  run_logged sudo apt-get update -qq
fi

henzos_ok "Package sources ready"
