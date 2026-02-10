#!/bin/bash
# Test script to validate OpenClaw Docker setup for Synology

set -e

echo "=== OpenClaw Docker Setup Validation ==="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}!${NC} $1"
}

# Test 1: Check Docker is available
echo "Test 1: Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    pass "Docker is installed: $DOCKER_VERSION"
else
    fail "Docker is not installed"
fi

# Test 2: Check Docker Compose is available
echo ""
echo "Test 2: Checking Docker Compose installation..."
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    pass "Docker Compose is available: $COMPOSE_VERSION"
else
    fail "Docker Compose is not available"
fi

# Test 3: Validate docker-compose.yml syntax
echo ""
echo "Test 3: Validating docker-compose.yml..."
if docker compose config > /dev/null 2>&1; then
    pass "docker-compose.yml syntax is valid"
else
    fail "docker-compose.yml has syntax errors"
fi

# Test 4: Check required files exist
echo ""
echo "Test 4: Checking required files..."
REQUIRED_FILES=(
    "Dockerfile"
    "docker-compose.yml"
    "entrypoint.sh"
    "README.md"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found: $file"
    else
        fail "Missing: $file"
    fi
done

# Test 5: Check directory structure
echo ""
echo "Test 5: Checking directory structure..."
REQUIRED_DIRS=(
    "assets"
    "config"
    "saves"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        pass "Found directory: $dir"
    else
        fail "Missing directory: $dir"
    fi
done

# Test 6: Check script permissions
echo ""
echo "Test 6: Checking script permissions..."
SCRIPTS=(
    "entrypoint.sh"
    "entrypoint-vnc.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            pass "$script is executable"
        else
            warn "$script is not executable (run: chmod +x $script)"
        fi
    fi
done

# Test 7: Check for optional VNC files
echo ""
echo "Test 7: Checking optional VNC support files..."
VNC_FILES=(
    "Dockerfile.vnc"
    "docker-compose.synology.yml"
    "supervisord.conf"
)

for file in "${VNC_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Found: $file"
    else
        warn "Optional file not found: $file"
    fi
done

# Test 8: Check for game assets
echo ""
echo "Test 8: Checking for game assets..."
if [ -f "assets/CLAW.REZ" ]; then
    pass "CLAW.REZ found in assets directory"
else
    warn "CLAW.REZ not found. You need to copy it from the original game."
fi

# Test 9: Validate Dockerfile syntax (basic check)
echo ""
echo "Test 9: Basic Dockerfile validation..."
if grep -q "^FROM " Dockerfile && grep -q "^WORKDIR " Dockerfile; then
    pass "Dockerfile has valid basic structure"
else
    fail "Dockerfile appears to be malformed"
fi

# Summary
echo ""
echo "=== Validation Summary ==="
echo ""
echo "✓ All critical checks passed!"
echo ""
echo "Next steps:"
echo "1. Copy CLAW.REZ to the assets/ directory"
echo "2. Run: docker compose build"
echo "3. Run: docker compose up -d"
echo "4. Check logs: docker compose logs -f"
echo ""
echo "For Synology-specific instructions, see SYNOLOGY_SETUP.md"
echo "For quick start guide, see QUICKSTART.md"
