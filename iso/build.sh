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

# Patch lb_binary_iso to allow squashfs >4GB (needed for arm64 builds)
LB_ISO="/usr/lib/live/build/lb_binary_iso"
if [ -f "$LB_ISO" ]; then
  sed -i 's/GENISOIMAGE_OPTIONS="-J -l -cache-inodes -allow-multidot"/GENISOIMAGE_OPTIONS="-J -l -cache-inodes -allow-multidot -allow-limited-size"/' "$LB_ISO"
fi

# Patch lb_binary_syslinux to create a minimal isolinux dir without needing
# syslinux-themes-ubuntu-oneiric or gfxboot-theme-ubuntu (removed in 24.04).
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

# Detect actual kernel/initrd filenames in casper/ (live-build uses versioned names)
KERNEL=$(ls binary/casper/vmlinuz* 2>/dev/null | head -1 | sed 's|binary/||')
INITRD=$(ls binary/casper/initrd* 2>/dev/null | head -1 | sed 's|binary/||')
KERNEL=${KERNEL:-casper/vmlinuz}
INITRD=${INITRD:-casper/initrd}

cat > "$ISOLINUX_DIR/isolinux.cfg" << CFG
DEFAULT live
LABEL live
  KERNEL /$KERNEL
  INITRD /$INITRD
  APPEND boot=casper quiet splash ---
CFG
SYSEOF
  chmod +x "$LB_SYSLINUX"
fi

# --- Binary hook: GRUB EFI for UEFI booting (x86_64 + arm64) ---
# NOTE: live-build looks for binary hooks in config/hooks/*.binary (not config/hooks/live/)
mkdir -p config/hooks
cat > config/hooks/03-grub-efi.binary << 'HOOKEOF'
#!/bin/bash
set -e

ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
  EFI_PKG="grub-efi-amd64-bin"
  EFI_FORMAT="x86_64-efi"
  EFI_FILE="BOOTX64.EFI"
else
  EFI_PKG="grub-efi-arm64-bin"
  EFI_FORMAT="arm64-efi"
  EFI_FILE="BOOTAA64.EFI"
fi

apt-get install -y -qq "$EFI_PKG" 2>/dev/null || true

# Detect actual kernel/initrd filenames
KERNEL=$(ls binary/casper/vmlinuz* 2>/dev/null | head -1 | sed 's|binary/||')
INITRD=$(ls binary/casper/initrd* 2>/dev/null | head -1 | sed 's|binary/||')
KERNEL=${KERNEL:-casper/vmlinuz}
INITRD=${INITRD:-casper/initrd}

# Create grub.cfg
mkdir -p binary/boot/grub
cat > binary/boot/grub/grub.cfg << GRUBCFG
set default=0
set timeout=5

search --no-floppy --label --set=root henzOS

menuentry "henzOS Live" {
  linux /$KERNEL boot=casper quiet splash ---
  initrd /$INITRD
}
GRUBCFG

# Create EFI/BOOT/<EFI_FILE> (standalone grub image with embedded config)
mkdir -p binary/EFI/BOOT
grub-mkstandalone \
  --format="$EFI_FORMAT" \
  --output="binary/EFI/BOOT/$EFI_FILE" \
  --locales="" \
  --fonts="" \
  "boot/grub/grub.cfg=binary/boot/grub/grub.cfg"
HOOKEOF
chmod +x config/hooks/03-grub-efi.binary

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

# --- Build (run each step individually, skip lb source) ---
echo "=> Running lb bootstrap..."
lb bootstrap

echo "=> Running lb chroot..."
lb chroot

echo "=> Running lb binary..."
lb binary

echo "=> Skipping lb source (not needed, fails on Ubuntu 24.04)"

# Move output
echo "=> Looking for ISO in $WORK_DIR..."
ls -la "$WORK_DIR"/*.iso "$WORK_DIR"/binary.iso 2>/dev/null || true
OUTPUT=""
for f in "$WORK_DIR"/binary.iso "$WORK_DIR"/*.iso; do
  if [ -f "$f" ]; then
    OUTPUT="$f"
    break
  fi
done
if [[ -n "$OUTPUT" ]]; then
  mv "$OUTPUT" "$ISO_DIR/henzos-${ARCH}-$(date +%Y%m%d).iso"
  echo ""
  echo "=> ISO built: $ISO_DIR/henzos-${ARCH}-$(date +%Y%m%d).iso"
else
  echo ""
  echo "=> ERROR: ISO not found. Check build logs in $WORK_DIR"
  exit 1
fi
