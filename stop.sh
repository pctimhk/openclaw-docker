#!/bin/bash
# OpenClaw Docker Stop Script for Synology

set -e

echo "Stopping OpenClaw Docker container..."

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

# Stop the containers
$DOCKER_COMPOSE down

echo ""
echo "OpenClaw has been stopped."
