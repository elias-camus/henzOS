# Interactive git configuration (only on first run)

if [[ "$HENZOS_FIRST_RUN" != "true" ]]; then
  return 0
fi

henzos_log "Configuring Git..."

# Only prompt if git user.name is not already set
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
  echo ""
  read -rp "   Git user.name: " git_name
  read -rp "   Git user.email: " git_email

  if [[ -n "$git_name" ]]; then
    git config --global user.name "$git_name"
  fi
  if [[ -n "$git_email" ]]; then
    git config --global user.email "$git_email"
  fi
fi

# henzOS git defaults
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true

henzos_ok "Git configured"
