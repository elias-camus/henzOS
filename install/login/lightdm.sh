# Configure LightDM with i3 session

henzos_log "Configuring LightDM..."

# Ensure i3 desktop session exists
if [[ ! -f /usr/share/xsessions/i3.desktop ]]; then
  sudo tee /usr/share/xsessions/i3.desktop > /dev/null << EOF
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
EOF
fi

# Configure LightDM greeter
sudo mkdir -p /etc/lightdm
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null << EOF
[greeter]
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = UDEV Gothic 35NF 11
background = #0b0f10
EOF

# Enable LightDM
run_logged sudo systemctl enable lightdm

henzos_ok "LightDM configured"
