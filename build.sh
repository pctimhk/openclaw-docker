#!/bin/bash
# OpenClaw Docker Build Script for Synology
# This script helps build and deploy OpenClaw on Synology NAS

set -e

echo "================================================"
echo "OpenClaw Docker Build Script for Synology"
echo "================================================"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Warning: docker-compose not found. Trying 'docker compose' instead..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Building OpenClaw Docker image..."
echo ""

# Build the image
docker build -t openclaw:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "Build successful!"
    echo "================================================"
    echo ""
    echo "To start OpenClaw, run:"
    echo "  $DOCKER_COMPOSE up -d"
    echo ""
    echo "To view logs, run:"
    echo "  $DOCKER_COMPOSE logs -f openclaw"
    echo ""
    echo "To run onboarding wizard, run:"
    echo "  docker exec -it openclaw-gateway openclaw onboard"
    echo ""
else
    echo ""
    echo "Build failed. Please check the error messages above."
    exit 1
fi
