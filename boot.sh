#!/usr/bin/env bash
set -euo pipefail

# henzOS - Beautiful, opinionated Ubuntu desktop
# Usage: curl -sL henzos.dev/install | bash

HENZOS_REPO="https://github.com/elias-camus/henzOS.git"
HENZOS_BRANCH="${HENZOS_BRANCH:-main}"
HENZOS_PATH="$HOME/.local/share/henzos"

cat << 'BANNER'

  ██╗  ██╗███████╗███╗   ██╗███████╗ ██████╗ ███████╗
  ██║  ██║██╔════╝████╗  ██║╚══███╔╝██╔═══██╗██╔════╝
  ███████║█████╗  ██╔██╗ ██║  ███╔╝ ██║   ██║███████╗
  ██╔══██║██╔══╝  ██║╚██╗██║ ███╔╝  ██║   ██║╚════██║
  ██║  ██║███████╗██║ ╚████║███████╗╚██████╔╝███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚══════╝

BANNER

echo "=> Installing henzOS on $(lsb_release -ds)..."
echo ""

# Ensure git is available
if ! command -v git &>/dev/null; then
  echo "=> Installing git..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq git
fi

# Clone or update
if [[ -d "$HENZOS_PATH/.git" ]]; then
  echo "=> Updating existing henzOS installation..."
  git -C "$HENZOS_PATH" fetch origin
  git -C "$HENZOS_PATH" checkout "$HENZOS_BRANCH"
  git -C "$HENZOS_PATH" reset --hard "origin/$HENZOS_BRANCH"
else
  echo "=> Cloning henzOS..."
  git clone --branch "$HENZOS_BRANCH" "$HENZOS_REPO" "$HENZOS_PATH"
fi

# Hand off to the main installer
source "$HENZOS_PATH/install.sh"
