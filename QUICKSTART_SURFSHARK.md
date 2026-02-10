# Surfshark VPN Quick Start Guide

## Quick Setup (5 minutes)

### 1. Get Surfshark Service Credentials

1. Go to https://my.surfshark.com/
2. Navigate to "VPN" → "Manual setup" 
3. Note your **Service credentials** (username and password)
   - ⚠️ These are NOT your regular login credentials
   - They are separate credentials specifically for VPN connections

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file
nano .env  # or use your favorite editor
```

Add your credentials:
```bash
# Enable Surfshark VPN
SURFSHARK_ENABLED=true

# Add your service credentials
SURFSHARK_USER=your_service_username_here
SURFSHARK_PASSWORD=your_service_password_here

# Optional: Choose server country (defaults to 'us')
SURFSHARK_COUNTRY=us
```

### 3. Start Container

```bash
# Build the image
docker-compose build

# Start the container
docker-compose up -d

# Watch the logs
docker-compose logs -f openclaw
```

### 4. Verify VPN Connection

You should see in the logs:
```
Surfshark VPN is enabled. Initializing VPN connection...
Connecting to Surfshark VPN server: us
VPN connection established successfully!
External IP: xxx.xxx.xxx.xxx
Starting OpenClaw Gateway
```

### 5. Confirm It's Working

```bash
# Check external IP from container (should show VPN IP)
docker exec openclaw-gateway wget -qO- https://api.ipify.org

# Check your host machine IP (should be different)
curl https://api.ipify.org
```

## Common Configurations

### US Server (Default)
```bash
SURFSHARK_ENABLED=true
SURFSHARK_USER=your_username
SURFSHARK_PASSWORD=your_password
SURFSHARK_COUNTRY=us
```

### UK Server
```bash
SURFSHARK_COUNTRY=uk
```

### Germany Server
```bash
SURFSHARK_COUNTRY=de
```

### Disable VPN
```bash
SURFSHARK_ENABLED=false
```

## Troubleshooting

### VPN not connecting?

1. **Check credentials:**
   ```bash
   # View logs
   docker-compose logs openclaw | grep -i error
   ```

2. **Verify subscription is active:**
   - Login to https://my.surfshark.com/
   - Check subscription status

3. **Try different server:**
   ```bash
   # In .env
   SURFSHARK_COUNTRY=uk  # Try UK instead of US
   ```

4. **Restart container:**
   ```bash
   docker-compose restart openclaw
   ```

### Container won't start?

```bash
# Check if tun device exists
ls -l /dev/net/tun

# Should show: crw-rw-rw- 1 root root 10, 200 ... /dev/net/tun
```

### Connection slow?

Try a server closer to your location:
- Europe: `uk`, `de`, `nl`, `fr`
- Americas: `us`, `ca`
- Asia: `jp`, `sg`, `hk`

### Can't access from outside network?

The VPN may block incoming connections. This is normal VPN behavior.

## Available Server Codes

Popular servers:
- `us` - United States
- `uk` - United Kingdom
- `de` - Germany
- `nl` - Netherlands
- `fr` - France
- `ca` - Canada
- `au` - Australia
- `jp` - Japan
- `sg` - Singapore
- `hk` - Hong Kong

Full list: https://support.surfshark.com/hc/en-us/articles/360011051133

## Security Tips

✅ **DO:**
- Keep your .env file secure
- Use strong, unique passwords
- Verify VPN connection after setup
- Monitor logs regularly

❌ **DON'T:**
- Commit .env file to git (it's in .gitignore)
- Share your service credentials
- Use your regular Surfshark login (use service credentials)
- Expose container ports unnecessarily

## Need More Help?

- **Full Documentation:** See `README.md` (Surfshark VPN Support section)
- **Testing Guide:** See `SURFSHARK_TESTING.md`
- **Security Review:** See `SECURITY_REVIEW.md`
- **Implementation Details:** See `IMPLEMENTATION_SUMMARY.md`

## Quick Commands Reference

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart openclaw

# View logs
docker-compose logs -f openclaw

# Check VPN status
docker exec openclaw-gateway ip addr show tun0

# Check external IP
docker exec openclaw-gateway wget -qO- https://api.ipify.org

# Rebuild after config changes
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Support

For Surfshark-specific issues: https://support.surfshark.com/  
For OpenClaw issues: https://github.com/OpenClaw/OpenClaw  
For this Docker setup: Open an issue in this repository

---

**Ready in 5 minutes!** 🚀
