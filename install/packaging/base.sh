# Install base packages from the package list

PACKAGES_FILE="$HENZOS_INSTALL/packaging/base.packages"

# Read package list, strip comments and blank lines
mapfile -t packages < <(
  sed 's/#.*//; /^\s*$/d' "$PACKAGES_FILE" | tr -s ' '
)

if [[ ${#packages[@]} -gt 0 ]]; then
  henzos_log "Installing ${#packages[@]} packages..."
  run_logged sudo apt-get install -y -qq "${packages[@]}"
  henzos_ok "Base packages installed"
else
  henzos_warn "No packages found in $PACKAGES_FILE"
fi

# --- Packages not in Ubuntu repos: install from binary releases ---

# lazygit
if ! command -v lazygit &>/dev/null; then
  henzos_log "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  LAZYGIT_ARCH=$(uname -m)
  case "$LAZYGIT_ARCH" in
    x86_64)
      LAZYGIT_ARCH="x86_64"
      ;;
    aarch64 | arm64)
      LAZYGIT_ARCH="arm64"
      ;;
    *)
      henzos_error "Unsupported architecture for lazygit: $LAZYGIT_ARCH"
      exit 1
      ;;
  esac
  TMPDIR=$(mktemp -d)
  curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
    | tar xz -C "$TMPDIR"
  sudo install "$TMPDIR/lazygit" /usr/local/bin/lazygit
  rm -rf "$TMPDIR"
  henzos_ok "lazygit $LAZYGIT_VERSION"
fi

# GitHub CLI
if ! command -v gh &>/dev/null; then
  henzos_log "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  run_logged sudo apt-get update -qq
  run_logged sudo apt-get install -y -qq gh
  henzos_ok "GitHub CLI"
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
  henzos_log "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y >> "$HENZOS_LOG" 2>&1
  henzos_ok "Starship"
fi

# Add user to docker group
if id -nG "$USER" | grep -qw docker; then
  : # already in group
else
  sudo usermod -aG docker "$USER"
  henzos_ok "Added $USER to docker group"
fi
