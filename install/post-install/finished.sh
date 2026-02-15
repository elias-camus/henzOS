# Installation complete

henzos_separator

cat << 'EOF'

  henzOS installation complete.

  What's next:
    - Log out and select "i3" from the session menu
    - Or reboot: sudo reboot

  Key bindings:
    Super+Return    Open terminal (Alacritty)
    Super+d         App launcher (Rofi)
    Super+Shift+q   Close window
    Super+Shift+r   Reload i3

  Commands:
    henzos-update         Update henzOS
    henzos-theme-set      Change theme
    henzos-wallpaper-set  Set wallpaper

EOF

henzos_separator

echo ""
read -rp "Reboot now? [y/N] " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
  sudo reboot
fi
