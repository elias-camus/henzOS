# Ensure we're running on a supported Ubuntu version

if [[ ! -f /etc/os-release ]]; then
  henzos_error "Cannot detect OS. /etc/os-release not found."
  exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
  henzos_error "henzOS requires Ubuntu. Detected: $ID"
  exit 1
fi

# Require Ubuntu 24.04+
MAJOR_VERSION="${VERSION_ID%%.*}"
if (( MAJOR_VERSION < 24 )); then
  henzos_error "henzOS requires Ubuntu 24.04 or later. Detected: $VERSION_ID"
  exit 1
fi

henzos_ok "Ubuntu $VERSION_ID ($VERSION_CODENAME)"
