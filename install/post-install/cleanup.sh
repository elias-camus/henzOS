# Post-install cleanup

henzos_log "Cleaning up..."

run_logged sudo apt-get autoremove -y -qq
run_logged sudo apt-get autoclean -y -qq

henzos_ok "Cleanup done"
