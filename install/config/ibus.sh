# Configure ibus for Japanese input

henzos_log "Configuring Japanese input (ibus-mozc)..."

# Set ibus as the input method framework
if ! grep -q "GTK_IM_MODULE=ibus" "$HOME/.profile" 2>/dev/null; then
  cat >> "$HOME/.profile" << 'EOF'

# henzOS: Japanese input method
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
EOF
fi

henzos_ok "ibus-mozc configured"
