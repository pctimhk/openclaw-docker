# Quick Setup Guide

This is a quick start guide to get OpenClaw running on your Synology NAS in just a few minutes.

## Prerequisites

- Synology NAS with Docker installed
- SSH access enabled
- At least 2GB RAM available

## 5-Minute Setup

### Step 1: Connect to NAS

```bash
ssh admin@YOUR_NAS_IP
```

### Step 2: Create Directory

```bash
cd /volume1/docker
mkdir openclaw
cd openclaw
```

### Step 3: Get Files

**Option A - Git (if available):**
```bash
git clone https://github.com/pctimhk/openclaw-docker.git .
```

**Option B - Manual:**
- Download zip from GitHub
- Upload to NAS via File Station

### Step 4: Configure

```bash
cp .env.example .env
nano .env
```

Add your API keys:
```env
ANTHROPIC_API_KEY=sk-ant-xxxxx
OPENAI_API_KEY=sk-xxxxx
```

Save: `Ctrl+X`, `Y`, `Enter`

### Step 5: Build & Start

```bash
sudo ./build.sh
sudo ./start.sh
```

### Step 6: Onboard

```bash
sudo docker exec -it openclaw-gateway openclaw onboard
```

Follow the wizard!

## Access

Gateway: `http://YOUR_NAS_IP:18789`

## Common Commands

```bash
# View logs
sudo docker compose logs -f openclaw

# Restart
sudo docker compose restart openclaw

# Stop
sudo ./stop.sh

# Update
sudo docker compose down
sudo docker compose pull
sudo docker compose build --no-cache
sudo docker compose up -d
```

## Troubleshooting

**Container won't start?**
```bash
sudo docker logs openclaw-gateway
```

**Port in use?**
```bash
sudo netstat -tulpn | grep 18789
```

**Need help?**
- Read: [README.md](README.md)
- Read: [SYNOLOGY_GUIDE.md](SYNOLOGY_GUIDE.md)
- Visit: [OpenClaw Discord](https://discord.gg/clawd)

## Next Steps

1. Configure channels (WhatsApp, Telegram, etc.)
2. Set up skills and capabilities
3. Configure reverse proxy for external access
4. Set up automated backups

See [SYNOLOGY_GUIDE.md](SYNOLOGY_GUIDE.md) for detailed instructions.
