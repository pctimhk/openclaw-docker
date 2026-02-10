# Synology-Specific Setup Guide for OpenClaw Docker

This guide provides detailed instructions for running OpenClaw on Synology NAS using Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuration](#configuration)
4. [Advanced Setup](#advanced-setup)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

### Hardware Requirements

- **NAS Models**: DS920+, DS1621+, DS1821+, DS918+, or any Synology NAS with Docker support
- **DSM Version**: 7.0 or higher (DSM 6.2+ may work but not tested)
- **RAM**: Minimum 2GB available (4GB+ recommended)
- **Storage**: At least 5GB free space

### Software Requirements

1. **Docker Package**: Install from Package Center
   - Open Package Center
   - Search for "Docker"
   - Click Install

2. **SSH Access** (for command-line installation):
   - Control Panel > Terminal & SNMP
   - Enable SSH service
   - Apply changes

## Installation Methods

### Method 1: Using SSH and Docker Compose (Recommended)

This method provides full control and easier updates.

#### Step 1: Connect to Your NAS

```bash
ssh admin@your-nas-ip
# Replace 'admin' with your Synology admin username
# Replace 'your-nas-ip' with your NAS IP address
```

#### Step 2: Create Project Directory

```bash
# Create directory in a shared folder
cd /volume1/docker  # or adjust to your volume
mkdir openclaw
cd openclaw
```

#### Step 3: Download Files

Option A - Using git (if available):
```bash
git clone https://github.com/pctimhk/openclaw-docker.git .
```

Option B - Manual download:
- Download files from this repository
- Upload to `/volume1/docker/openclaw` via File Station

#### Step 4: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
# Or use: vi .env
```

Add your API keys and adjust settings:
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxx
OPENAI_API_KEY=sk-xxxxx
TZ=America/New_York  # Your timezone
```

Save and exit (Ctrl+X, then Y, then Enter in nano).

#### Step 5: Build and Start

```bash
# Build the image
sudo ./build.sh

# Start the service
sudo ./start.sh
```

#### Step 6: Run Onboarding

```bash
sudo docker exec -it openclaw-gateway openclaw onboard
```

Follow the interactive wizard to complete setup.

### Method 2: Using Synology Docker GUI

This method uses Synology's graphical interface.

#### Step 1: Prepare Files

1. Download all files from this repository to your computer
2. Open File Station on your Synology
3. Create folder: `docker/openclaw`
4. Upload all files to this folder

#### Step 2: Build Image via SSH

You still need SSH for building the image:

```bash
ssh admin@your-nas-ip
cd /volume1/docker/openclaw
sudo docker build -t openclaw:latest .
```

Wait for build to complete (5-10 minutes depending on NAS performance).

#### Step 3: Create Container via Docker UI

1. Open Docker package in DSM
2. Go to **Image** tab
3. Find `openclaw:latest` image
4. Select it and click **Launch**

#### Step 4: Configure Container

**General Settings:**
- Container Name: `openclaw-gateway`
- Enable auto-restart: ✓

**Advanced Settings > Volume:**
- Add folder: `/volume1/docker/openclaw/data` → `/data/openclaw`
- Add folder: `/volume1/docker/openclaw/config` → `/data/config`

**Advanced Settings > Port:**
- Local Port: `18789` → Container Port: `18789`
- Protocol: TCP

**Advanced Settings > Environment:**
Add variables:
```
NODE_ENV=production
OPENCLAW_HOME=/data/openclaw
OPENCLAW_CONFIG=/data/config
TZ=UTC
ANTHROPIC_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
```

**Advanced Settings > Resource Limitation:**
- Memory limit: 2048 MB
- CPU priority: High (optional)

#### Step 5: Start Container

Click **Apply** and **Start**.

#### Step 6: Run Onboarding

Via SSH:
```bash
sudo docker exec -it openclaw-gateway openclaw onboard
```

## Configuration

### Accessing the Gateway

Once running, access the gateway at:
- Internal: `http://your-nas-ip:18789`
- External: Configure reverse proxy (see below)

### Setting Up Reverse Proxy

For secure external access:

1. **Control Panel > Login Portal > Advanced**
2. Click **Reverse Proxy**
3. Click **Create**
4. Configure:
   - Description: OpenClaw
   - Source:
     - Protocol: HTTPS
     - Hostname: openclaw.yourdomain.com
     - Port: 443
     - Enable HSTS: ✓
   - Destination:
     - Protocol: HTTP
     - Hostname: localhost
     - Port: 18789

5. Set up SSL certificate (Control Panel > Security > Certificate)

### Configuring Channels

After onboarding, you can configure communication channels:

```bash
sudo docker exec -it openclaw-gateway sh
openclaw channel add --type whatsapp
openclaw channel add --type telegram
openclaw channel add --type slack
# etc.
```

## Advanced Setup

### Using Named Volumes

For better data management:

1. Edit `docker-compose.yml`:

```yaml
volumes:
  - openclaw_data:/data/openclaw
  - openclaw_config:/data/config

volumes:
  openclaw_data:
    driver: local
  openclaw_config:
    driver: local
```

2. Restart:
```bash
sudo docker-compose down
sudo docker-compose up -d
```

### Running Multiple Instances

To run multiple OpenClaw instances:

1. Create separate directories:
```bash
mkdir -p /volume1/docker/openclaw-1
mkdir -p /volume1/docker/openclaw-2
```

2. Copy files to each directory

3. Edit `docker-compose.yml` in each, change:
   - Container name
   - Port mapping (e.g., 18789 → 18790)

4. Start each instance separately

### Backup and Restore

#### Backup

```bash
# Stop container
sudo docker-compose down

# Backup data
sudo tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz /volume1/docker/openclaw/data

# Restart
sudo docker-compose up -d
```

#### Restore

```bash
# Stop container
sudo docker-compose down

# Restore data
sudo tar -xzf openclaw-backup-YYYYMMDD.tar.gz -C /

# Restart
sudo docker-compose up -d
```

### Scheduled Tasks

Set up automatic backups using Task Scheduler:

1. Control Panel > Task Scheduler
2. Create > Scheduled Task > User-defined script
3. General: Name "OpenClaw Backup", User "root"
4. Schedule: Daily at 2 AM
5. Task Settings:
```bash
cd /volume1/docker/openclaw
docker-compose down
tar -czf /volume1/backups/openclaw-$(date +%Y%m%d).tar.gz data
docker-compose up -d
```

## Troubleshooting

### Container Fails to Start

**Issue**: Container status shows "Exited"

**Solutions**:
1. Check logs:
   ```bash
   sudo docker logs openclaw-gateway
   ```

2. Verify permissions:
   ```bash
   sudo chown -R 1000:1000 /volume1/docker/openclaw/data
   ```

3. Check port conflicts:
   ```bash
   sudo netstat -tulpn | grep 18789
   ```

### High Memory Usage

**Issue**: Container uses too much RAM

**Solutions**:
1. Reduce memory limit in docker-compose.yml:
   ```yaml
   mem_limit: 1g
   ```

2. Monitor usage:
   ```bash
   sudo docker stats openclaw-gateway
   ```

3. Restart container:
   ```bash
   sudo docker-compose restart
   ```

### Cannot Access Gateway

**Issue**: Gateway unreachable from browser

**Solutions**:
1. Verify container is running:
   ```bash
   sudo docker ps | grep openclaw
   ```

2. Check firewall rules:
   - Control Panel > Security > Firewall
   - Ensure port 18789 is allowed

3. Test locally:
   ```bash
   curl http://localhost:18789/health
   ```

### API Key Errors

**Issue**: Authentication failures with AI providers

**Solutions**:
1. Verify API keys in .env file
2. Restart container after changing keys:
   ```bash
   sudo docker-compose restart
   ```

3. Re-run onboarding:
   ```bash
   sudo docker exec -it openclaw-gateway openclaw onboard
   ```

### Slow Performance

**Issue**: OpenClaw responds slowly

**Solutions**:
1. Check NAS resource usage:
   - Resource Monitor in DSM

2. Allocate more CPU:
   ```yaml
   cpus: "4.0"
   ```

3. Use SSD cache if available

4. Upgrade NAS RAM if possible

## Performance Optimization

### For DS920+ / DS918+

```yaml
mem_limit: 2g
mem_reservation: 1g
cpus: "2.0"
```

### For DS1621+ / DS1821+

```yaml
mem_limit: 4g
mem_reservation: 2g
cpus: "4.0"
```

### For Higher-End Models

```yaml
mem_limit: 8g
mem_reservation: 4g
cpus: "8.0"
```

## Maintenance

### Regular Updates

Update monthly or when new versions are released:

```bash
cd /volume1/docker/openclaw
sudo docker-compose down
sudo docker-compose pull
sudo docker-compose build --no-cache
sudo docker-compose up -d
```

### Log Rotation

To prevent logs from consuming too much space:

Edit `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker service:
```bash
sudo synoservicectl --restart pkgctl-Docker
```

## Security Best Practices

1. **Use Strong Passwords**: Set strong admin password
2. **Enable 2FA**: Control Panel > Security > Account
3. **Firewall**: Enable and configure firewall rules
4. **SSL/TLS**: Use HTTPS with valid certificates
5. **Regular Updates**: Keep DSM and Docker updated
6. **Backup API Keys**: Store securely offline
7. **Monitor Logs**: Check for suspicious activity
8. **Network Isolation**: Consider VLANs for Docker containers

## Getting Help

- **Synology Issues**: Synology Support or /r/synology
- **Docker Issues**: Docker documentation
- **OpenClaw Issues**: OpenClaw Discord or GitHub

## Additional Resources

- [Synology Docker Documentation](https://www.synology.com/en-us/dsm/packages/Docker)
- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
