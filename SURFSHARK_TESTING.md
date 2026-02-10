# Surfshark VPN Integration - Testing Guide

This document provides comprehensive testing instructions for the Surfshark VPN integration with OpenClaw Docker.

## Prerequisites

1. Active Surfshark VPN subscription
2. Surfshark service credentials (from Surfshark account dashboard under "Manual Setup")
3. Docker and Docker Compose installed
4. `/dev/net/tun` device available (should be available on most Linux systems)

## Test Setup

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/pctimhk/openclaw-docker.git
   cd openclaw-docker
   ```

2. **Create `.env` file** from the example:
   ```bash
   cp .env.example .env
   ```

3. **Configure Surfshark credentials** in `.env`:
   ```bash
   # Enable Surfshark VPN
   SURFSHARK_ENABLED=true
   
   # Add your Surfshark service credentials
   SURFSHARK_USER=your_service_username_here
   SURFSHARK_PASSWORD=your_service_password_here
   
   # Optional: Choose server country (defaults to 'us')
   SURFSHARK_COUNTRY=us
   ```

## Test Cases

### Test 1: VPN Disabled (Default Behavior)

**Purpose**: Verify OpenClaw works normally without VPN

1. Set in `.env`:
   ```bash
   SURFSHARK_ENABLED=false
   ```

2. Build and start:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

3. Check logs:
   ```bash
   docker-compose logs openclaw
   ```

4. **Expected result**:
   - Logs show: "Surfshark VPN is disabled. Starting OpenClaw directly..."
   - No VPN connection attempts
   - OpenClaw starts successfully
   - Health check passes

### Test 2: VPN Enabled with Valid Credentials

**Purpose**: Verify VPN connects successfully before OpenClaw starts

1. Set in `.env`:
   ```bash
   SURFSHARK_ENABLED=true
   SURFSHARK_USER=your_actual_username
   SURFSHARK_PASSWORD=your_actual_password
   SURFSHARK_COUNTRY=us
   ```

2. Rebuild and start:
   ```bash
   docker-compose down
   docker-compose build
   docker-compose up -d
   ```

3. Watch logs in real-time:
   ```bash
   docker-compose logs -f openclaw
   ```

4. **Expected result**:
   - Logs show: "Surfshark VPN is enabled. Initializing VPN connection..."
   - Logs show: "Connecting to Surfshark VPN server: us"
   - Logs show: "VPN connection established successfully!"
   - Logs show external IP address (VPN IP)
   - OpenClaw starts after VPN is connected
   - Health check passes

5. **Verify VPN IP** (from host):
   ```bash
   docker exec openclaw-gateway wget -qO- https://api.ipify.org
   ```
   This should show a different IP than your host machine's IP.

### Test 3: VPN Enabled with Invalid Credentials

**Purpose**: Verify proper error handling for authentication failures

1. Set in `.env`:
   ```bash
   SURFSHARK_ENABLED=true
   SURFSHARK_USER=invalid_user
   SURFSHARK_PASSWORD=invalid_pass
   ```

2. Start container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Check logs:
   ```bash
   docker-compose logs openclaw
   ```

4. **Expected result**:
   - Container starts VPN connection attempt
   - VPN connection fails within 30 seconds
   - Error message displayed
   - Container exits with error (won't start OpenClaw)

### Test 4: VPN Enabled without Credentials

**Purpose**: Verify validation of required environment variables

1. Set in `.env`:
   ```bash
   SURFSHARK_ENABLED=true
   # Comment out credentials
   # SURFSHARK_USER=
   # SURFSHARK_PASSWORD=
   ```

2. Start container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Check logs:
   ```bash
   docker-compose logs openclaw
   ```

4. **Expected result**:
   - Logs show: "ERROR: SURFSHARK_USER and SURFSHARK_PASSWORD must be set when SURFSHARK_ENABLED=true"
   - Container exits immediately with error code 1
   - OpenClaw does not start

### Test 5: Different VPN Server Countries

**Purpose**: Verify ability to connect to different Surfshark servers

1. Test with different countries:
   ```bash
   # UK server
   SURFSHARK_COUNTRY=uk
   
   # Germany
   SURFSHARK_COUNTRY=de
   
   # Netherlands
   SURFSHARK_COUNTRY=nl
   
   # Japan
   SURFSHARK_COUNTRY=jp
   ```

2. For each country:
   ```bash
   docker-compose down
   # Update SURFSHARK_COUNTRY in .env
   docker-compose up -d
   docker-compose logs -f openclaw
   ```

3. **Expected result**:
   - Each country connects successfully
   - External IP matches the selected country's location
   - Different connection times may occur based on server location

### Test 6: Container Restart Behavior

**Purpose**: Verify VPN reconnects properly on container restart

1. Start with VPN enabled
2. Wait for successful connection
3. Restart container:
   ```bash
   docker-compose restart openclaw
   ```

4. Check logs:
   ```bash
   docker-compose logs openclaw
   ```

5. **Expected result**:
   - VPN reconnects on restart
   - OpenClaw starts after VPN connection
   - No persistent connection issues

### Test 7: Required Capabilities

**Purpose**: Verify container has necessary permissions for VPN

1. Check container capabilities:
   ```bash
   docker exec openclaw-gateway sh -c "cat /proc/1/status | grep Cap"
   ```

2. Verify `/dev/net/tun` is accessible:
   ```bash
   docker exec openclaw-gateway ls -l /dev/net/tun
   ```

3. **Expected result**:
   - Container has NET_ADMIN and NET_RAW capabilities
   - `/dev/net/tun` device is present and accessible

## Troubleshooting Tests

### Check VPN Process

```bash
docker exec openclaw-gateway ps aux | grep openvpn
```

Expected: OpenVPN process running

### Check Network Interface

```bash
docker exec openclaw-gateway ip addr show tun0
```

Expected: tun0 interface exists with IP address

### Check VPN Logs

```bash
docker exec openclaw-gateway cat /var/log/openvpn.log
```

### Check DNS Resolution

```bash
docker exec openclaw-gateway nslookup google.com
```

Expected: DNS resolution works through VPN

### Manual IP Check

From inside container:
```bash
docker exec openclaw-gateway wget -qO- https://api.ipify.org
```

From host (for comparison):
```bash
curl https://api.ipify.org
```

IPs should be different if VPN is working.

## Performance Tests

### Connection Time

Measure time from container start to OpenClaw ready:

```bash
time docker-compose up -d && docker-compose logs -f openclaw | grep -m 1 "Starting OpenClaw Gateway"
```

Expected: < 60 seconds with VPN enabled

### Health Check

Verify health check passes with VPN:

```bash
docker inspect openclaw-gateway | grep -A 10 Health
```

Expected: Status: healthy

## Cleanup

After testing:

```bash
docker-compose down
docker rmi openclaw:latest
```

## Test Summary Checklist

- [ ] Test 1: VPN disabled - OpenClaw starts normally
- [ ] Test 2: VPN enabled with valid credentials - VPN connects, OpenClaw starts
- [ ] Test 3: VPN enabled with invalid credentials - Proper error handling
- [ ] Test 4: VPN enabled without credentials - Validation error
- [ ] Test 5: Different server countries - All connect successfully
- [ ] Test 6: Container restart - VPN reconnects properly
- [ ] Test 7: Required capabilities - All present
- [ ] Troubleshooting: VPN process running
- [ ] Troubleshooting: tun0 interface exists
- [ ] Troubleshooting: DNS resolution works
- [ ] Troubleshooting: External IP matches VPN server location
- [ ] Performance: Connection time acceptable
- [ ] Performance: Health checks pass

## Notes for Synology Users

On Synology NAS, ensure:

1. Docker package is up to date (DSM 7.0+)
2. SSH access is enabled
3. TUN/TAP support is available (should be by default)
4. Run commands with `sudo` if not root user

Example:
```bash
sudo docker-compose up -d
sudo docker-compose logs -f openclaw
```
