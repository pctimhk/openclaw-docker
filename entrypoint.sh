#!/bin/sh
# OpenClaw Docker Entrypoint with VPN Support
# This script connects to VPN (if enabled) before starting OpenClaw

set -e

log() {
    echo "[ENTRYPOINT] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting OpenClaw with VPN support..."

# Run VPN connection script
if [ -f /app/vpn-connect.sh ]; then
    if /app/vpn-connect.sh; then
        log "VPN connection completed successfully"
    else
        if [ "${VPN_REQUIRED:-false}" = "true" ]; then
            log "ERROR: VPN connection required but failed"
            exit 1
        else
            log "WARNING: VPN connection failed but continuing (VPN_REQUIRED=false)"
        fi
    fi
else
    log "WARNING: VPN connection script not found, skipping VPN setup"
fi

# Display connection information
if command -v curl >/dev/null 2>&1; then
    log "Checking connection..."
    EXTERNAL_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "unknown")
    log "External IP: $EXTERNAL_IP"
fi

# Start OpenClaw
log "Starting OpenClaw gateway..."
exec "$@"
