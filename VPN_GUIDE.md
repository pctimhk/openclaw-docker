# Surfshark VPN Integration Guide

This guide explains how to set up and use Surfshark VPN with OpenClaw Docker.

## Overview

OpenClaw Docker now supports automatic VPN connection before starting the application. This is useful for:
- Privacy and security
- Accessing region-restricted content
- Running OpenClaw through a VPN tunnel
- Network anonymization

## Prerequisites

- Active Surfshark VPN subscription
- Surfshark service credentials (see below)
- Docker with NET_ADMIN capability support
- `/dev/net/tun` device access

## Getting Surfshark Service Credentials

**Important**: The credentials needed are **NOT** your Surfshark account login credentials. You need to generate service credentials for manual setup.

### Steps to Get Service Credentials:

1. **Log in to Surfshark**:
   - Go to https://my.surfshark.com

2. **Navigate to Manual Setup**:
   - Click on "VPN" in the left menu
   - Select "Manual setup"
   - Choose "Credentials"

3. **Get Your Credentials**:
   - You'll see a **Username** (looks like: `sxxxxxx`)
   - You'll see a **Password** (a long string of characters)
   - These are your service credentials (also called "login code")

4. **Copy These Credentials**:
   - Copy both the username and password
   - You'll need these for the Docker configuration

### Credential Types Explained:

| Type | Example | Used For |
|------|---------|----------|
| **Account Login** | `your-email@example.com` | Logging into Surfshark website |
| **Service Credentials** | `s123456789` (username)<br>`abcd1234efgh5678` (password) | OpenVPN/WireGuard connections |

⚠️ **Use Service Credentials, NOT Account Login!**

## Configuration

### Option 1: Using Environment Variables in .env

1. **Copy the example configuration**:
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file**:
   ```bash
   nano .env
   ```

3. **Set VPN configuration**:
   ```env
   # Enable VPN
   VPN_ENABLED=true
   
   # VPN Type (currently only openvpn is supported)
   VPN_TYPE=openvpn
   
   # Surfshark service credentials
   SURFSHARK_USER=s123456789
   SURFSHARK_PASSWORD=your_service_password_here
   
   # Country code (us, uk, de, nl, jp, etc.)
   SURFSHARK_COUNTRY=us
   
   # Fail if VPN connection fails (recommended: true)
   VPN_REQUIRED=true
   ```

4. **Save and exit**: Press `Ctrl+X`, then `Y`, then `Enter`

### Option 2: Using docker-compose.yml

Edit `docker-compose.yml` and uncomment/set the VPN environment variables:

```yaml
environment:
  - VPN_ENABLED=true
  - VPN_TYPE=openvpn
  - SURFSHARK_USER=s123456789
  - SURFSHARK_PASSWORD=your_service_password_here
  - SURFSHARK_COUNTRY=us
  - VPN_REQUIRED=true
```

## Available Country Codes

Common country codes for Surfshark:

| Country | Code | Country | Code |
|---------|------|---------|------|
| United States | `us` | United Kingdom | `uk` |
| Canada | `ca` | Australia | `au` |
| Germany | `de` | Netherlands | `nl` |
| France | `fr` | Switzerland | `ch` |
| Japan | `jp` | Singapore | `sg` |
| Hong Kong | `hk` | India | `in` |
| Brazil | `br` | Italy | `it` |
| Spain | `es` | Sweden | `se` |
| Norway | `no` | Denmark | `dk` |

For a complete list, visit: https://my.surfshark.com/vpn/manual-setup/main

## Starting with VPN

### First Time Setup

1. **Configure VPN settings** (see Configuration above)

2. **Build the container**:
   ```bash
   sudo docker-compose build
   ```

3. **Start the container**:
   ```bash
   sudo docker-compose up -d
   ```

4. **Check VPN connection**:
   ```bash
   sudo docker-compose logs openclaw | grep VPN
   ```

   You should see:
   ```
   [VPN] 2024-01-15 10:30:00 - VPN is enabled, establishing connection...
   [VPN] 2024-01-15 10:30:05 - Connecting to Surfshark via OpenVPN...
   [VPN] 2024-01-15 10:30:15 - VPN interface (tun0) is up
   [VPN] 2024-01-15 10:30:18 - ✓ VPN connection established successfully
   [ENTRYPOINT] 2024-01-15 10:30:18 - External IP: 1.2.3.4
   ```

### Verifying VPN Connection

Check your external IP to verify VPN is working:

```bash
# From inside the container
sudo docker exec openclaw-gateway curl -s https://api.ipify.org
```

Compare this IP with your actual IP address to confirm VPN is active.

### Checking VPN Status

```bash
# Check if VPN interface is up
sudo docker exec openclaw-gateway ip link show tun0

# Check OpenVPN process
sudo docker exec openclaw-gateway pgrep openvpn

# View VPN logs
sudo docker exec openclaw-gateway tail -f /var/log/openvpn.log
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VPN_ENABLED` | `false` | Enable VPN connection |
| `VPN_TYPE` | `openvpn` | VPN type (openvpn or wireguard) |
| `SURFSHARK_USER` | - | Surfshark service username |
| `SURFSHARK_PASSWORD` | - | Surfshark service password |
| `SURFSHARK_COUNTRY` | `us` | Country code for VPN server |
| `VPN_REQUIRED` | `false` | Fail container start if VPN fails |

### VPN_REQUIRED Setting

- **`true`**: Container will not start if VPN connection fails (recommended for privacy-critical applications)
- **`false`**: Container will start even if VPN fails, but a warning will be logged

## Troubleshooting

### VPN Connection Fails

**Check credentials**:
```bash
sudo docker-compose logs openclaw | grep "ERROR"
```

Common error: "Auth failed" - Your service credentials are incorrect or expired.

**Solution**:
1. Regenerate service credentials at https://my.surfshark.com/vpn/manual-setup/main
2. Update your `.env` file with new credentials
3. Restart: `sudo docker-compose restart openclaw`

### Cannot Download VPN Configurations

**Error**: "Failed to download VPN configurations"

**Solution**:
1. Check internet connectivity: `sudo docker exec openclaw-gateway ping -c 3 8.8.8.8`
2. Check DNS: `sudo docker exec openclaw-gateway nslookup my.surfshark.com`
3. Verify firewall isn't blocking downloads

### VPN Connects But No Internet

**Check routing**:
```bash
sudo docker exec openclaw-gateway ip route
sudo docker exec openclaw-gateway ping -c 3 8.8.8.8
```

**Solution**:
1. Restart the container: `sudo docker-compose restart openclaw`
2. Check if DNS is working: `sudo docker exec openclaw-gateway nslookup google.com`
3. Try a different country: Change `SURFSHARK_COUNTRY` in `.env`

### VPN Process Dies

**Check logs**:
```bash
sudo docker exec openclaw-gateway tail -20 /var/log/openvpn.log
```

**Common causes**:
- Invalid configuration file
- Network interruption
- Server maintenance

**Solution**:
1. Try a different country server
2. Check Surfshark status: https://surfshark.com/server-status
3. Restart container: `sudo docker-compose restart openclaw`

### Container Won't Start with VPN Enabled

**Error**: "ERROR: VPN connection required but failed"

**Steps**:
1. **Check logs**: `sudo docker-compose logs openclaw`
2. **Test credentials manually**:
   ```bash
   sudo docker-compose run --rm openclaw sh
   # Inside container:
   echo "$SURFSHARK_USER"
   echo "$SURFSHARK_PASSWORD"
   ```
3. **Set VPN_REQUIRED=false temporarily** to debug
4. **Verify /dev/net/tun access**:
   ```bash
   sudo docker-compose run --rm openclaw ls -la /dev/net/tun
   ```

### Permission Denied Errors

**Error**: "Cannot open TUN/TAP device"

**Solution**:
Ensure docker-compose.yml has:
```yaml
cap_add:
  - NET_ADMIN
  - SYS_MODULE
devices:
  - /dev/net/tun
```

## Security Considerations

1. **Protect Credentials**:
   - Never commit `.env` file to git
   - Use `.gitignore` to exclude `.env`
   - Keep credentials secure

2. **VPN_REQUIRED**:
   - Set to `true` for privacy-critical applications
   - Prevents data leaks if VPN fails

3. **Monitor Connection**:
   - Regularly check VPN is connected
   - Set up alerts for VPN disconnections
   - Review logs periodically

4. **Kill Switch**:
   - The container uses `VPN_REQUIRED=true` as a kill switch
   - If VPN disconnects, container will fail health checks

## Advanced Configuration

### Custom OpenVPN Configuration

If you need custom OpenVPN settings:

1. **Download configuration manually**:
   ```bash
   cd /volume1/docker/openclaw
   mkdir -p ovpn-config
   # Download from Surfshark and place in ovpn-config/
   ```

2. **Mount configuration**:
   ```yaml
   volumes:
     - ./ovpn-config:/etc/openvpn:ro
   ```

3. **Disable auto-download**:
   Set a custom environment variable in vpn-connect.sh

### Using Different VPN Protocols

Currently, only OpenVPN is supported. WireGuard support is planned for a future release.

To use WireGuard (when available):
```env
VPN_TYPE=wireguard
```

## Performance

### VPN Impact

- **Latency**: Expect 10-50ms additional latency
- **Bandwidth**: Usually 80-95% of your normal speed
- **CPU**: Minimal impact (< 5% on most systems)

### Optimizing Performance

1. **Choose Nearby Servers**:
   - Use a country close to your location
   - Example: US East if you're in New York

2. **UDP vs TCP**:
   - Default is UDP (faster)
   - TCP is more reliable but slower

3. **Change Servers**:
   - If slow, try a different country
   - Some servers may be congested

## FAQ

**Q: Do I need VPN for OpenClaw?**
A: No, VPN is optional. Enable it only if you need privacy or region-specific access.

**Q: Can I use other VPN providers?**
A: This integration is specifically designed for Surfshark. Other providers would require code modifications.

**Q: What happens if VPN disconnects?**
A: If `VPN_REQUIRED=true`, the health check will eventually fail and container will restart. If `false`, OpenClaw continues without VPN.

**Q: Can I change countries without rebuilding?**
A: Yes, just change `SURFSHARK_COUNTRY` in `.env` and restart: `sudo docker-compose restart openclaw`

**Q: Does VPN work on Synology?**
A: Yes, as long as your Synology supports Docker with NET_ADMIN capabilities (most models do).

**Q: Is WireGuard faster than OpenVPN?**
A: Generally yes, but WireGuard support is not yet implemented. Use OpenVPN for now.

## Support

For VPN-related issues:
1. Check this guide's troubleshooting section
2. Review container logs: `sudo docker-compose logs openclaw`
3. Check Surfshark status: https://surfshark.com/server-status
4. Open an issue on GitHub with logs (remove sensitive info)

For Surfshark account issues:
- Contact Surfshark support: https://support.surfshark.com

## References

- [Surfshark Manual Setup](https://my.surfshark.com/vpn/manual-setup/main)
- [OpenVPN Documentation](https://openvpn.net/community-resources/)
- [Surfshark Server Status](https://surfshark.com/server-status)
- [Docker Networking](https://docs.docker.com/network/)
