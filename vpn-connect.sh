#!/bin/sh
# Surfshark VPN Connection Script
# This script handles VPN connection before starting the main application

set -e

VPN_ENABLED="${VPN_ENABLED:-false}"
VPN_TYPE="${VPN_TYPE:-openvpn}"

log() {
    echo "[VPN] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

check_vpn_connection() {
    # Check if VPN is connected by testing external IP
    if command -v curl >/dev/null 2>&1; then
        EXTERNAL_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "")
        if [ -n "$EXTERNAL_IP" ]; then
            log "External IP: $EXTERNAL_IP"
            return 0
        fi
    fi
    return 1
}

connect_openvpn() {
    log "Connecting to Surfshark via OpenVPN..."
    
    # Check required variables
    if [ -z "$SURFSHARK_USER" ] || [ -z "$SURFSHARK_PASSWORD" ]; then
        log "ERROR: SURFSHARK_USER and SURFSHARK_PASSWORD must be set"
        return 1
    fi
    
    if [ -z "$SURFSHARK_COUNTRY" ]; then
        SURFSHARK_COUNTRY="us"
        log "No country specified, using default: us"
    fi
    
    # Create credentials file
    echo "$SURFSHARK_USER" > /tmp/vpn-credentials.txt
    echo "$SURFSHARK_PASSWORD" >> /tmp/vpn-credentials.txt
    chmod 600 /tmp/vpn-credentials.txt
    
    # Download Surfshark OpenVPN config if not present
    if [ ! -f "/etc/openvpn/${SURFSHARK_COUNTRY}.prod.surfshark.com_udp.ovpn" ]; then
        log "Downloading Surfshark OpenVPN configuration..."
        mkdir -p /etc/openvpn
        
        # Download configurations from Surfshark
        cd /etc/openvpn
        curl -s "https://my.surfshark.com/vpn/api/v1/server/configurations" -o configs.zip
        
        if [ -f configs.zip ]; then
            unzip -q configs.zip
            rm configs.zip
        else
            log "ERROR: Failed to download VPN configurations"
            return 1
        fi
    fi
    
    # Find configuration file
    CONFIG_FILE=$(find /etc/openvpn -name "${SURFSHARK_COUNTRY}*.ovpn" | head -n 1)
    
    if [ -z "$CONFIG_FILE" ]; then
        log "ERROR: Configuration file for country '$SURFSHARK_COUNTRY' not found"
        log "Available configurations:"
        ls -1 /etc/openvpn/*.ovpn 2>/dev/null || echo "None"
        return 1
    fi
    
    log "Using configuration: $CONFIG_FILE"
    
    # Update config to use credentials file
    if ! grep -q "auth-user-pass /tmp/vpn-credentials.txt" "$CONFIG_FILE"; then
        sed -i 's/auth-user-pass/auth-user-pass \/tmp\/vpn-credentials.txt/' "$CONFIG_FILE"
    fi
    
    # Start OpenVPN in background
    log "Starting OpenVPN connection..."
    openvpn --config "$CONFIG_FILE" --daemon --log /var/log/openvpn.log
    
    # Wait for connection
    log "Waiting for VPN connection..."
    RETRY=0
    MAX_RETRIES=30
    
    while [ $RETRY -lt $MAX_RETRIES ]; do
        sleep 2
        
        # Check if OpenVPN process is running
        if ! pgrep openvpn >/dev/null; then
            log "ERROR: OpenVPN process died"
            if [ -f /var/log/openvpn.log ]; then
                log "Last 10 lines of OpenVPN log:"
                tail -n 10 /var/log/openvpn.log
            fi
            return 1
        fi
        
        # Check for tun interface
        if ip link show tun0 >/dev/null 2>&1; then
            log "VPN interface (tun0) is up"
            sleep 3  # Give it a bit more time to stabilize
            
            if check_vpn_connection; then
                log "✓ VPN connection established successfully"
                return 0
            fi
        fi
        
        RETRY=$((RETRY + 1))
        log "Waiting for connection... ($RETRY/$MAX_RETRIES)"
    done
    
    log "ERROR: VPN connection timeout"
    return 1
}

connect_wireguard() {
    log "WireGuard support not yet implemented"
    log "Please use VPN_TYPE=openvpn"
    return 1
}

# Main execution
if [ "$VPN_ENABLED" = "true" ] || [ "$VPN_ENABLED" = "1" ] || [ "$VPN_ENABLED" = "yes" ]; then
    log "VPN is enabled, establishing connection..."
    
    case "$VPN_TYPE" in
        openvpn)
            if connect_openvpn; then
                log "VPN connection successful"
                exit 0
            else
                log "VPN connection failed"
                exit 1
            fi
            ;;
        wireguard)
            if connect_wireguard; then
                log "VPN connection successful"
                exit 0
            else
                log "VPN connection failed"
                exit 1
            fi
            ;;
        *)
            log "ERROR: Unknown VPN type: $VPN_TYPE"
            log "Supported types: openvpn, wireguard"
            exit 1
            ;;
    esac
else
    log "VPN is disabled, skipping connection"
    exit 0
fi
