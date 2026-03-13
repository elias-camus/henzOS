# Install fonts for henzOS

henzos_log "Installing fonts..."

# System fonts via apt
run_logged sudo apt-get install -y -qq \
  fonts-noto \
  fonts-noto-cjk \
  fonts-noto-color-emoji

FONT_BASE="$HOME/.local/share/fonts"
mkdir -p "$FONT_BASE"

# UDEV Gothic 35NF (primary monospace font)
if [[ ! -d "$FONT_BASE/UDEVGothicNF" ]]; then
  henzos_log "Installing UDEV Gothic NF..."
  UDEV_VERSION=$(curl -s https://api.github.com/repos/yuru7/udev-gothic/releases/latest | jq -r '.tag_name')
  TMPDIR=$(mktemp -d)
  curl -sL "https://github.com/yuru7/udev-gothic/releases/download/${UDEV_VERSION}/UDEVGothic_NF_${UDEV_VERSION}.zip" \
    -o "$TMPDIR/udev.zip"
  unzip -qo "$TMPDIR/udev.zip" -d "$TMPDIR"
  mkdir -p "$FONT_BASE/UDEVGothicNF"
  find "$TMPDIR" -name "*.ttf" -exec cp {} "$FONT_BASE/UDEVGothicNF/" \;
  rm -rf "$TMPDIR"
fi

# JetBrains Mono Nerd Font (Neovim GUI, fallback)
if [[ ! -d "$FONT_BASE/JetBrainsMonoNF" ]]; then
  henzos_log "Installing JetBrains Mono Nerd Font..."
  TMPDIR=$(mktemp -d)
  curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o "$TMPDIR/jb.zip"
  unzip -qo "$TMPDIR/jb.zip" -d "$TMPDIR"
  mkdir -p "$FONT_BASE/JetBrainsMonoNF"
  find "$TMPDIR" -name "*.ttf" -exec cp {} "$FONT_BASE/JetBrainsMonoNF/" \;
  rm -rf "$TMPDIR"
fi

fc-cache -f
henzos_ok "Fonts installed"
