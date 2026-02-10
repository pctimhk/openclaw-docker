#!/bin/bash
set -e

echo "Starting OpenClaw Docker Container with VNC support..."

# Create necessary directories
mkdir -p /openclaw/ASSETS
mkdir -p /openclaw/config
mkdir -p /openclaw/saves
mkdir -p ~/.vnc

# Set VNC password
VNC_PASSWORD=${VNC_PASSWORD:-openclaw}
echo "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Create VNC xstartup script
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x ~/.vnc/xstartup

# Check if CLAW.REZ exists
if [ ! -f "/openclaw/ASSETS/CLAW.REZ" ]; then
    echo "WARNING: CLAW.REZ not found in /openclaw/ASSETS/"
    echo "Please place the CLAW.REZ file from the original game in the assets directory"
    echo "You need to own the original Captain Claw game to use this"
fi

# Check if openclaw binary exists
if [ ! -f "/openclaw/openclaw" ]; then
    echo "ERROR: OpenClaw binary not found!"
    exit 1
fi

echo "================================================"
echo "OpenClaw with VNC is ready!"
echo "================================================"
echo "VNC Server: Port 5900"
echo "noVNC Web: Port 6080"
echo "VNC Password: $VNC_PASSWORD"
echo "Resolution: ${VNC_RESOLUTION:-1024x768}"
echo ""
echo "Connect using:"
echo "  - VNC Client: vnc://your-nas-ip:5900"
echo "  - Web Browser: http://your-nas-ip:6080"
echo ""
echo "Game assets directory: /openclaw/ASSETS"
echo "Config directory: /openclaw/config"
echo "Saves directory: /openclaw/saves"
echo "================================================"

# Execute the command passed to the container
exec "$@"
