#!/usr/bin/env bash
set -euo pipefail

# henzOS installer - main orchestrator
# Can be run directly for local development:
#   cd ~/.local/share/henzos && source install.sh

export HENZOS_PATH="${HENZOS_PATH:-$HOME/.local/share/henzos}"
export HENZOS_INSTALL="$HENZOS_PATH/install"
export HENZOS_CONFIG="$HOME/.config/henzos"
export HENZOS_LOG="/tmp/henzos-install.log"
export PATH="$HENZOS_PATH/bin:$PATH"

# Phase 0: Load helpers
source "$HENZOS_INSTALL/helpers/all.sh"

# Phase 1: Preflight checks
source "$HENZOS_INSTALL/preflight/all.sh"

# Phase 2: Install packages
source "$HENZOS_INSTALL/packaging/all.sh"

# Phase 3: Deploy configuration
source "$HENZOS_INSTALL/config/all.sh"

# Phase 4: Login / display manager
source "$HENZOS_INSTALL/login/all.sh"

# Phase 5: Post-install
source "$HENZOS_INSTALL/post-install/all.sh"
