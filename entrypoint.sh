#!/bin/sh
# OpenClaw Docker Entrypoint Script with Surfshark VPN Support

set -e

echo "=== OpenClaw Docker Container Starting ==="

# Function to connect to Surfshark VPN
connect_surfshark() {
    echo "Surfshark VPN is enabled. Initializing VPN connection..."
    
    # Check if credentials are provided
    if [ -z "$SURFSHARK_USER" ] || [ -z "$SURFSHARK_PASSWORD" ]; then
        echo "ERROR: SURFSHARK_USER and SURFSHARK_PASSWORD must be set when SURFSHARK_ENABLED=true"
        exit 1
    fi
    
    # Default to US server if country not specified
    COUNTRY="${SURFSHARK_COUNTRY:-us}"
    SERVER_HOSTNAME="${COUNTRY}-prod.prod.surfshark.com"
    echo "Connecting to Surfshark VPN server: $COUNTRY ($SERVER_HOSTNAME)"
    
    # Create auth file for OpenVPN
    echo "$SURFSHARK_USER" > /tmp/surfshark-auth.txt
    echo "$SURFSHARK_PASSWORD" >> /tmp/surfshark-auth.txt
    chmod 600 /tmp/surfshark-auth.txt
    
    # Download Surfshark OpenVPN configuration if not present
    if [ ! -f "/etc/openvpn/surfshark-${COUNTRY}.ovpn" ]; then
        echo "Downloading Surfshark configuration for $COUNTRY..."
        mkdir -p /etc/openvpn
        
        # Surfshark uses standard OpenVPN configs available from their site
        # Try to download the config file from multiple sources
        API_URL_1="https://api.surfshark.com/v1/server/configurations/${SERVER_HOSTNAME}_udp.ovpn"
        API_URL_2="https://my.surfshark.com/vpn/api/v1/server/configurations/${SERVER_HOSTNAME}_udp.ovpn"
        
        if wget -q -O "/etc/openvpn/surfshark-${COUNTRY}.ovpn" "$API_URL_1"; then
            echo "Successfully downloaded configuration from primary API"
        elif wget -q -O "/etc/openvpn/surfshark-${COUNTRY}.ovpn" "$API_URL_2"; then
            echo "Successfully downloaded configuration from secondary API"
        else
            echo "WARNING: Could not download Surfshark config from:"
            echo "  - $API_URL_1"
            echo "  - $API_URL_2"
            echo "Creating fallback OpenVPN configuration..."
            # Create a basic OpenVPN config as fallback
            cat > "/etc/openvpn/surfshark-${COUNTRY}.ovpn" <<EOF
client
dev tun
proto udp
remote $SERVER_HOSTNAME 1194
resolv-retry infinite
remote-random
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
ping 15
ping-restart 0
ping-timer-rem
reneg-sec 0
comp-lzo no
verify-x509-name $SERVER_HOSTNAME name
remote-cert-tls server

auth-user-pass /tmp/surfshark-auth.txt
verb 3
pull
fast-io
cipher AES-256-CBC
auth SHA512
EOF
        fi
    fi
    
    # Start OpenVPN in the background
    echo "Starting OpenVPN connection..."
    openvpn --config "/etc/openvpn/surfshark-${COUNTRY}.ovpn" \
        --auth-user-pass /tmp/surfshark-auth.txt \
        --daemon \
        --log /var/log/openvpn.log
    
    # Wait for VPN connection to establish
    echo "Waiting for VPN connection to establish..."
    MAX_WAIT=30
    COUNTER=0
    
    while [ $COUNTER -lt $MAX_WAIT ]; do
        # Check if tun0 interface exists
        if ip addr show tun0 > /dev/null 2>&1; then
            echo "VPN connection established successfully!"
            
            # Show the external IP for verification
            sleep 2
            echo "Verifying external IP address..."
            if EXTERNAL_IP=$(wget -qO- --timeout=5 https://api.ipify.org 2>/dev/null); then
                echo "External IP: $EXTERNAL_IP"
            else
                echo "VPN connected but could not verify external IP (network check failed)"
                echo "This is normal if internet connectivity is limited during startup"
            fi
            
            return 0
        fi
        
        sleep 1
        COUNTER=$((COUNTER + 1))
        
        # Show progress
        if [ $((COUNTER % 5)) -eq 0 ]; then
            echo "Still waiting for VPN connection... ($COUNTER/$MAX_WAIT seconds)"
        fi
    done
    
    # If we reach here, VPN connection failed
    echo "ERROR: Failed to establish VPN connection within $MAX_WAIT seconds"
    echo "OpenVPN log:"
    cat /var/log/openvpn.log 2>/dev/null || echo "No log file found"
    exit 1
}

# Check if Surfshark VPN should be enabled
if [ "$SURFSHARK_ENABLED" = "true" ] || [ "$SURFSHARK_ENABLED" = "1" ]; then
    connect_surfshark
else
    echo "Surfshark VPN is disabled. Starting OpenClaw directly..."
fi

# Start OpenClaw
echo "=== Starting OpenClaw Gateway ==="
exec "$@"
