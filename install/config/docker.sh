# Configure Docker

henzos_log "Configuring Docker..."

# Enable and start Docker service
run_logged sudo systemctl enable docker
run_logged sudo systemctl start docker

henzos_ok "Docker configured"
