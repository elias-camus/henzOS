#!/usr/bin/env bash
set -euo pipefail

# henzOS ISO builder
# Uses live-build to create a bootable Ubuntu 24.04 LTS ISO with henzOS pre-installed.
#
# Prerequisites:
#   sudo apt-get install live-build
#
# Usage:
#   cd iso/ && sudo bash build.sh

ISO_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$ISO_DIR/work"
HENZOS_ROOT="$(dirname "$ISO_DIR")"

echo "=> Building henzOS ISO..."

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# --- Configure live-build ---
lb config \
  --distribution noble \
  --archive-areas "main restricted universe multiverse" \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootappend-live "boot=casper quiet splash" \
  --debian-installer none \
  --image-name "henzos" \
  --iso-application "henzOS" \
  --iso-volume "henzOS"

# --- Package list ---
mkdir -p config/package-lists
cat > config/package-lists/henzos.list.chroot << 'PKGEOF'
# Core desktop
i3-wm xorg picom polybar rofi dunst alacritty feh
xss-lock i3lock xdotool xclip xsel arandr libnotify-bin
lightdm lightdm-gtk-greeter

# Editor
neovim

# Shell / CLI
bash-completion fzf ripgrep bat tmux jq tree curl wget git
unzip zip build-essential pkg-config cmake

# System
network-manager pulseaudio pavucontrol brightnessctl udiskie upower
thunar gvfs gvfs-backends tumbler

# Containers
docker.io docker-compose

# Japanese
ibus ibus-mozc

# Browser
firefox

# Media
mpv imv ffmpeg maim slop

# Appearance
lxappearance dex papirus-icon-theme
fonts-noto fonts-noto-cjk fonts-noto-color-emoji

# Tools
software-properties-common ca-certificates gnupg
PKGEOF

# --- Hook: install henzOS on first boot ---
mkdir -p config/includes.chroot/etc/skel/.local/share
cp -R "$HENZOS_ROOT" config/includes.chroot/etc/skel/.local/share/henzos

mkdir -p config/hooks/live
cat > config/hooks/live/01-henzos.hook.chroot << 'HOOKEOF'
#!/bin/bash
# Enable LightDM
systemctl enable lightdm

# Create i3 session file
mkdir -p /usr/share/xsessions
cat > /usr/share/xsessions/i3.desktop << XEOF
[Desktop Entry]
Name=i3
Comment=henzOS desktop
Exec=i3
TryExec=i3
Type=Application
XEOF
HOOKEOF
chmod +x config/hooks/live/01-henzos.hook.chroot

# --- Auto-setup script for first login ---
mkdir -p config/includes.chroot/etc/skel/.config/autostart
cat > config/includes.chroot/etc/skel/.config/autostart/henzos-setup.desktop << 'AUTOEOF'
[Desktop Entry]
Type=Application
Name=henzOS Setup
Exec=bash -c 'if [ ! -f ~/.config/henzos/version ]; then alacritty -e bash -c "source ~/.local/share/henzos/install.sh"; fi'
X-GNOME-Autostart-enabled=true
AUTOEOF

# --- Build ---
echo "=> Running lb build (this requires root)..."
lb build

# Move output
mv "$WORK_DIR/henzos-amd64.hybrid.iso" "$ISO_DIR/henzos-$(date +%Y%m%d).iso" 2>/dev/null || true

echo ""
echo "=> ISO built: $ISO_DIR/henzos-$(date +%Y%m%d).iso"
