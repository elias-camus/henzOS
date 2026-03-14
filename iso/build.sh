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
ARCH="$(dpkg --print-architecture)"  # amd64 or arm64

echo "=> Building henzOS ISO (${ARCH})..."

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# --- Configure live-build ---
lb config \
  --distribution noble \
  --archive-areas "main restricted universe multiverse" \
  --architectures "$ARCH" \
  --bootappend-live "boot=casper quiet splash" \
  --debian-installer false \
  --iso-application "henzOS" \
  --iso-volume "henzOS" \
  --linux-flavours "generic" \
  --binary-images iso \
  --source false

# Patch lb_binary_syslinux to create a minimal isolinux dir without needing
# syslinux-themes-ubuntu-oneiric or gfxboot-theme-ubuntu (removed in 24.04).
# The script is replaced with one that sets up a bare-minimum isolinux config
# so that genisoimage can find the boot catalog directory.
LB_SYSLINUX="/usr/lib/live/build/lb_binary_syslinux"
if [ -f "$LB_SYSLINUX" ]; then
  cp "$LB_SYSLINUX" "${LB_SYSLINUX}.bak"
  cat > "$LB_SYSLINUX" << 'SYSEOF'
#!/bin/sh
set -e
# Minimal syslinux/isolinux setup for live-build on Ubuntu 24.04
# (replaces the default script that requires removed theme packages)
apt-get install -y -qq syslinux syslinux-common isolinux 2>/dev/null || true

ISOLINUX_DIR="binary/isolinux"
mkdir -p "$ISOLINUX_DIR"

# Copy isolinux binary
for f in /usr/lib/ISOLINUX/isolinux.bin /usr/lib/syslinux/modules/bios/ldlinux.c32; do
  [ -f "$f" ] && cp "$f" "$ISOLINUX_DIR/"
done

# Minimal config
cat > "$ISOLINUX_DIR/isolinux.cfg" << 'CFG'
DEFAULT live
LABEL live
  KERNEL /casper/vmlinuz
  INITRD /casper/initrd
  APPEND boot=casper quiet splash ---
CFG
SYSEOF
  chmod +x "$LB_SYSLINUX"
fi

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

# Live environment
casper

# Boot (architecture-specific packages added dynamically below)
PKGEOF

# --- Architecture-specific boot packages ---
if [ "$ARCH" = "amd64" ]; then
  echo "grub-efi-amd64-signed grub-pc-bin shim-signed" \
    >> config/package-lists/henzos.list.chroot
else
  echo "grub-efi-arm64 shim-signed" \
    >> config/package-lists/henzos.list.chroot
fi

# --- Include henzOS files in the live filesystem ---
# These go into /etc/skel so every user (including the live user) gets them
SKEL="config/includes.chroot/etc/skel"
mkdir -p "$SKEL/.local/share"

# Copy henzOS repo (excluding .git, iso/work to save space)
rsync -a --exclude='.git' --exclude='iso/work' "$HENZOS_ROOT/" "$SKEL/.local/share/henzos/"

# --- Pre-deploy dotfiles and theme into skel ---
# This means the live environment boots with everything already configured,
# no need to run install.sh on first login.

# Deploy config files
mkdir -p "$SKEL/.config"
cp -R "$HENZOS_ROOT/config/"* "$SKEL/.config/"

# Set up theme symlink (emerald as default)
mkdir -p "$SKEL/.config/henzos/current"
# Can't use symlinks in skel easily, so we copy the theme
cp -R "$HENZOS_ROOT/themes/emerald" "$SKEL/.config/henzos/current/theme"

# Version marker
echo "1.0.0" > "$SKEL/.config/henzos/version"

# Starship config
cp "$HENZOS_ROOT/config/starship.toml" "$SKEL/.config/starship.toml"

# Bashrc
mkdir -p "$SKEL/.config/henzos"
cp "$HENZOS_ROOT/default/bashrc" "$SKEL/.bashrc"

# --- Chroot hook: system-level configuration ---
mkdir -p config/hooks/live
cat > config/hooks/live/01-henzos.hook.chroot << 'HOOKEOF'
#!/bin/bash
set -e

# Enable LightDM
systemctl enable lightdm

# Disable cloud-init (not needed for desktop)
touch /etc/cloud/cloud-init.disabled

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

# Install Starship prompt system-wide
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install lazygit
LAZYGIT_ARCH=$(dpkg --print-architecture)
case "$LAZYGIT_ARCH" in
  amd64) LAZYGIT_ARCH="x86_64" ;;
  arm64) LAZYGIT_ARCH="arm64" ;;
esac
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed 's/.*"v//;s/".*//')
curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
  | tar xz -C /usr/local/bin lazygit

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  > /etc/apt/sources.list.d/github-cli.list
apt-get update -qq
apt-get install -y -qq gh

# Set default session to i3 for LightDM
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-henzos.conf << LDMEOF
[Seat:*]
user-session=i3
LDMEOF

# Git defaults
git config --system init.defaultBranch main
git config --system pull.rebase true
git config --system push.autoSetupRemote true
HOOKEOF
chmod +x config/hooks/live/01-henzos.hook.chroot

# --- Font installation hook (separate, runs in chroot) ---
cat > config/hooks/live/02-fonts.hook.chroot << 'HOOKEOF'
#!/bin/bash
set -e

FONT_BASE="/usr/share/fonts/truetype/henzos"
mkdir -p "$FONT_BASE"

# UDEV Gothic NF
UDEV_VERSION=$(curl -s https://api.github.com/repos/yuru7/udev-gothic/releases/latest | grep '"tag_name"' | sed 's/.*"//;s/".*//')
TMPDIR=$(mktemp -d)
curl -sL "https://github.com/yuru7/udev-gothic/releases/download/${UDEV_VERSION}/UDEVGothic_NF_${UDEV_VERSION}.zip" \
  -o "$TMPDIR/udev.zip"
unzip -qo "$TMPDIR/udev.zip" -d "$TMPDIR"
find "$TMPDIR" -name "*.ttf" -exec cp {} "$FONT_BASE/" \;
rm -rf "$TMPDIR"

# JetBrains Mono Nerd Font
TMPDIR=$(mktemp -d)
curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
  -o "$TMPDIR/jb.zip"
unzip -qo "$TMPDIR/jb.zip" -d "$TMPDIR"
find "$TMPDIR" -name "*.ttf" -exec cp {} "$FONT_BASE/" \;
rm -rf "$TMPDIR"

fc-cache -f
HOOKEOF
chmod +x config/hooks/live/02-fonts.hook.chroot

# --- Build ---
echo "=> Running lb build (this requires root)..."
# lb_source may exit 2 even with --source false; run in subshell to catch it
LB_EXIT=0
(lb build) || LB_EXIT=$?
if [ $LB_EXIT -ne 0 ]; then
  # Check if ISO was actually created despite the error
  if ls "$WORK_DIR"/binary.iso "$WORK_DIR"/*.hybrid.iso "$WORK_DIR"/*.iso 2>/dev/null | head -1 | grep -q .; then
    echo "=> lb build exited with $LB_EXIT but ISO was generated, continuing..."
  else
    echo "=> ERROR: lb build failed with exit code $LB_EXIT"
    exit $LB_EXIT
  fi
fi

# Move output
OUTPUT=$(ls "$WORK_DIR"/binary.iso "$WORK_DIR"/*.hybrid.iso "$WORK_DIR"/*.iso 2>/dev/null | head -1)
if [[ -n "$OUTPUT" ]]; then
  mv "$OUTPUT" "$ISO_DIR/henzos-${ARCH}-$(date +%Y%m%d).iso"
  echo ""
  echo "=> ISO built: $ISO_DIR/henzos-${ARCH}-$(date +%Y%m%d).iso"
else
  echo ""
  echo "=> ERROR: ISO not found. Check build logs in $WORK_DIR"
  exit 1
fi
