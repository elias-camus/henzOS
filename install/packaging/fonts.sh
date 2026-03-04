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
if [[ ! -d "$FONT_BASE/UDEVGothic35NF" ]]; then
  henzos_log "Installing UDEV Gothic 35NF..."
  UDEV_VERSION="v2.0.0"
  TMPDIR=$(mktemp -d)
  curl -sL "https://github.com/yuru7/udev-gothic/releases/download/${UDEV_VERSION}/UDEVGothic35NF_${UDEV_VERSION}.zip" \
    -o "$TMPDIR/udev.zip"
  unzip -qo "$TMPDIR/udev.zip" -d "$TMPDIR"
  mkdir -p "$FONT_BASE/UDEVGothic35NF"
  find "$TMPDIR" -name "*.ttf" -exec cp {} "$FONT_BASE/UDEVGothic35NF/" \;
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
