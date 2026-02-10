# Quick Start Guide for Synology

This guide will help you get OpenClaw running on your Synology NAS in just a few steps.

## What You Need

1. ✅ Synology NAS with Docker installed
2. ✅ CLAW.REZ file from the original Captain Claw game
3. ✅ Basic knowledge of File Station or SSH

## Installation Methods

Choose the method that works best for you:

### Method 1: Simple Setup (File Station Only) 🌟 RECOMMENDED

**Step 1: Prepare Folders**
1. Open **File Station** on your Synology
2. Navigate to a shared folder (e.g., `docker`)
3. Create a new folder called `openclaw`
4. Inside `openclaw`, create three subfolders:
   - `assets`
   - `config`
   - `saves`

**Step 2: Upload Files**
1. Download all files from this repository
2. Upload these files to `/docker/openclaw/`:
   - `Dockerfile`
   - `docker-compose.yml`
   - `entrypoint.sh`
3. Upload your `CLAW.REZ` file to `/docker/openclaw/assets/`

**Step 3: Build and Run**
1. Open **Docker** app in DSM
2. Go to **Registry** tab
3. Search for `ubuntu` and download `ubuntu:22.04`
4. Use SSH or File Station to access Terminal:
   ```bash
   cd /volume1/docker/openclaw
   sudo docker compose build
   sudo docker compose up -d
   ```

### Method 2: With VNC (For GUI Access) 🖥️

If you want to play the game through your browser:

**Step 1-2**: Same as Method 1

**Step 3: Use VNC Version**
1. In Step 2, also upload:
   - `Dockerfile.vnc`
   - `entrypoint-vnc.sh`
   - `supervisord.conf`
   - `docker-compose.synology.yml`

2. Via SSH:
   ```bash
   cd /volume1/docker/openclaw
   sudo docker compose -f docker-compose.yml -f docker-compose.synology.yml build
   sudo docker compose -f docker-compose.yml -f docker-compose.synology.yml up -d
   ```

3. Access the game at: `http://your-nas-ip:6080`

### Method 3: Using Synology Docker GUI 🖱️

**Step 1: Build Image**
1. Open **Docker** app
2. Go to **Image** → **Add** → **Add from Folder**
3. Select the folder containing Dockerfile
4. Wait for build (10-30 minutes)

**Step 2: Create Container**
1. Select `openclaw:latest` image
2. Click **Launch**
3. Set **Container name**: `openclaw`
4. Enable **Auto-restart**
5. **Volume** tab:
   - `/docker/openclaw/assets` → `/openclaw/ASSETS`
   - `/docker/openclaw/config` → `/openclaw/config`
   - `/docker/openclaw/saves` → `/openclaw/saves`
6. **Port** tab (if using VNC):
   - Container: `5900` → Local: `5900`
   - Container: `6080` → Local: `6080`
7. **Environment** tab:
   - `TZ` = `Your/Timezone`
   - `VNC_PASSWORD` = `openclaw` (if using VNC)
8. Click **Apply**

## Verify Installation

### Check Container Status
```bash
sudo docker ps | grep openclaw
```

### View Logs
```bash
sudo docker logs openclaw
```

### Access the Game
- **VNC Method**: Open browser to `http://your-nas-ip:6080`
- **VNC Client**: Connect to `your-nas-ip:5900` (password: openclaw)

## Testing Checklist

- [ ] Container is running: `docker ps` shows openclaw
- [ ] CLAW.REZ is in assets folder
- [ ] No errors in logs: `docker logs openclaw`
- [ ] Can access VNC (if enabled): http://nas-ip:6080
- [ ] Game launches without errors

## Common Issues

### "CLAW.REZ not found"
**Fix**: Copy CLAW.REZ to `/volume1/docker/openclaw/assets/`

### "Permission denied"
**Fix**: 
```bash
sudo chmod -R 777 /volume1/docker/openclaw
```

### Container won't start
**Fix**: Check logs:
```bash
sudo docker logs openclaw
```

### Can't connect to VNC
**Fix**: 
1. Check firewall settings in DSM
2. Verify ports 5900 and 6080 are not blocked
3. Try accessing via local network first

## Next Steps

1. ✅ Copy CLAW.REZ to assets folder
2. ✅ Start container: `sudo docker compose up -d`
3. ✅ Access game via VNC: `http://your-nas-ip:6080`
4. ✅ Enjoy playing Captain Claw!

## Getting Help

- Check logs: `sudo docker logs openclaw`
- Restart container: `sudo docker restart openclaw`
- View this guide: `SYNOLOGY_SETUP.md` for detailed info
- GitHub Issues: Report problems on the repository

## File Structure Summary

```
/volume1/docker/openclaw/
├── assets/
│   └── CLAW.REZ          # Your game file
├── config/
│   └── (game configs)
├── saves/
│   └── (save games)
├── Dockerfile
├── docker-compose.yml
└── entrypoint.sh
```

## Maintenance

### Update Container
```bash
cd /volume1/docker/openclaw
sudo docker compose pull
sudo docker compose up -d
```

### Backup Saves
Backup folder: `/volume1/docker/openclaw/saves/`

### Remove Container
```bash
sudo docker compose down
```

---

**Need more help?** Check the full README.md or SYNOLOGY_SETUP.md for detailed instructions.
