#!/bin/bash
set -e

echo "Starting OpenClaw Docker Container..."

# Create necessary directories
mkdir -p /openclaw/ASSETS
mkdir -p /openclaw/config
mkdir -p /openclaw/saves

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

echo "OpenClaw is ready!"
echo "Game assets directory: /openclaw/ASSETS"
echo "Config directory: /openclaw/config"
echo "Saves directory: /openclaw/saves"

# Execute the command passed to the container
exec "$@"
