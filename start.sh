#!/bin/bash
# OpenClaw Docker Start Script for Synology

set -e

echo "Starting OpenClaw Docker container..."

# Check if docker-compose is installed
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "Error: Neither docker-compose nor 'docker compose' found"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if .env exists, if not copy from example
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "Please edit .env file with your configuration before starting."
    echo "Run: nano .env"
    exit 1
fi

# Create data directories if they don't exist
mkdir -p data/openclaw data/config

# Start the containers
$DOCKER_COMPOSE up -d

echo ""
echo "OpenClaw is starting..."
echo "To view logs: $DOCKER_COMPOSE logs -f openclaw"
echo "To run onboarding: docker exec -it openclaw-gateway openclaw onboard"
echo "Gateway URL: http://localhost:18789"
