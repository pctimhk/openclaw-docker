# Troubleshooting Guide for OpenClaw on Synology

This guide helps you resolve common issues when running OpenClaw Docker on Synology NAS.

## Table of Contents

1. [Container Issues](#container-issues)
2. [Build Problems](#build-problems)
3. [Game Asset Issues](#game-asset-issues)
4. [VNC/GUI Issues](#vncgui-issues)
5. [Performance Issues](#performance-issues)
6. [Synology-Specific Issues](#synology-specific-issues)

---

## Container Issues

### Container Won't Start

**Symptom**: Container immediately exits or restarts continuously

**Solutions**:

1. Check logs:
   ```bash
   docker logs openclaw
   ```

2. Verify Docker service is running:
   ```bash
   docker ps
   ```

3. Check if port conflicts exist (especially 5900, 6080):
   ```bash
   netstat -tulpn | grep -E '5900|6080'
   ```

4. Restart Docker service on Synology:
   - Go to **Package Center** → **Docker** → Stop → Start

### Permission Denied Errors

**Symptom**: "Permission denied" when accessing files

**Solutions**:

1. Fix directory permissions:
   ```bash
   sudo chmod -R 777 /volume1/docker/openclaw
   ```

2. Check volume mounts have correct ownership:
   ```bash
   ls -la /volume1/docker/openclaw/
   ```

3. If using File Station, ensure shared folder permissions allow Docker access

### Container Exits with Code 1

**Symptom**: Container runs but exits with error code 1

**Solutions**:

1. OpenClaw binary not found - rebuild the image:
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

2. Check entrypoint script syntax:
   ```bash
   bash -n entrypoint.sh
   ```

---

## Build Problems

### Build Takes Too Long

**Symptom**: Docker build hangs or takes over 1 hour

**Solutions**:

1. Check Synology CPU usage:
   - Open **Resource Monitor** in DSM

2. Build with fewer parallel jobs:
   - Edit Dockerfile: Change `make -j$(nproc)` to `make -j2`

3. Ensure enough free space:
   ```bash
   df -h /volume1
   ```

### Build Fails: "Cannot clone repository"

**Symptom**: Git clone fails during build

**Solutions**:

1. Check internet connectivity:
   ```bash
   ping -c 3 github.com
   ```

2. Check DNS settings in DSM:
   - **Control Panel** → **Network** → **General** → DNS Server

3. Try building with manual git clone:
   ```bash
   git clone https://github.com/pjasicek/OpenClaw.git
   # Then modify Dockerfile to use local copy
   ```

### Build Fails: "Missing dependencies"

**Symptom**: CMake or make fails with missing library errors

**Solutions**:

1. Rebuild without cache:
   ```bash
   docker compose build --no-cache
   ```

2. Check Dockerfile apt-get commands executed successfully

3. Verify base Ubuntu image is correct:
   ```bash
   docker images | grep ubuntu
   ```

---

## Game Asset Issues

### "CLAW.REZ not found"

**Symptom**: Warning about missing CLAW.REZ file

**Solutions**:

1. Verify file is in correct location:
   ```bash
   ls -lh /volume1/docker/openclaw/assets/CLAW.REZ
   ```

2. Check filename is EXACTLY `CLAW.REZ` (case-sensitive):
   ```bash
   find /volume1/docker/openclaw/assets/ -iname "*claw*"
   ```

3. Ensure file is not corrupted (should be ~20-30MB):
   ```bash
   du -h /volume1/docker/openclaw/assets/CLAW.REZ
   ```

4. Copy from original game CD or installation

### Volume Mount Not Working

**Symptom**: Changes to assets folder not reflected in container

**Solutions**:

1. Restart container:
   ```bash
   docker restart openclaw
   ```

2. Verify mount points:
   ```bash
   docker inspect openclaw | grep -A 5 "Mounts"
   ```

3. Check if using correct path in docker-compose.yml:
   ```yaml
   volumes:
     - ./assets:/openclaw/ASSETS  # Relative path
     # OR
     - /volume1/docker/openclaw/assets:/openclaw/ASSETS  # Absolute path
   ```

---

## VNC/GUI Issues

### Cannot Connect to VNC

**Symptom**: VNC client cannot connect to port 5900

**Solutions**:

1. Check if VNC port is exposed:
   ```bash
   docker port openclaw
   ```

2. Verify firewall rules in DSM:
   - **Control Panel** → **Security** → **Firewall**
   - Allow ports 5900 and 6080

3. Try connecting from local network first:
   ```bash
   telnet your-nas-ip 5900
   ```

4. Check VNC server is running in container:
   ```bash
   docker exec openclaw ps aux | grep vnc
   ```

### Black Screen in VNC

**Symptom**: VNC connects but shows only black screen

**Solutions**:

1. Check if X server is running:
   ```bash
   docker exec openclaw ps aux | grep X
   ```

2. Restart container with fresh session:
   ```bash
   docker restart openclaw
   ```

3. Check supervisord logs:
   ```bash
   docker exec openclaw cat /var/log/supervisor/supervisord.log
   ```

### noVNC Web Interface Not Working

**Symptom**: Cannot access http://nas-ip:6080

**Solutions**:

1. Verify noVNC is running:
   ```bash
   docker logs openclaw | grep novnc
   ```

2. Check port mapping:
   ```bash
   docker port openclaw 6080
   ```

3. Try accessing via different browser

4. Clear browser cache and cookies

---

## Performance Issues

### Game Runs Slowly

**Symptom**: Low FPS or laggy gameplay

**Solutions**:

1. Check Synology CPU usage:
   - **Resource Monitor** → **Performance**

2. Increase CPU allocation in docker-compose.synology.yml:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '4.0'  # Increase this
         memory: 4G   # Increase this
   ```

3. Close other Docker containers to free resources

4. Check if Synology is performing background tasks (backup, indexing)

### High Memory Usage

**Symptom**: Container uses too much RAM

**Solutions**:

1. Check actual memory usage:
   ```bash
   docker stats openclaw
   ```

2. Set memory limits in docker-compose.yml:
   ```yaml
   mem_limit: 2g
   ```

3. Restart container to clear memory:
   ```bash
   docker restart openclaw
   ```

---

## Synology-Specific Issues

### Docker Package Not Available

**Symptom**: Cannot find Docker in Package Center

**Solutions**:

1. Check DSM version (need DSM 7.0+):
   - **Control Panel** → **Info Center**

2. Check CPU architecture:
   - Docker is available for x86_64 (Intel/AMD) NAS models
   - ARM models may not support Docker

3. Update DSM to latest version

### Insufficient Storage Space

**Symptom**: "No space left on device" during build

**Solutions**:

1. Check available space:
   ```bash
   df -h
   ```

2. Clean up Docker:
   ```bash
   docker system prune -a
   ```

3. Move Docker folder to volume with more space:
   - **Docker** → **Settings** → Change Docker Root Directory

### Container Stops After NAS Reboot

**Symptom**: Container doesn't auto-start after Synology restarts

**Solutions**:

1. Set restart policy:
   ```yaml
   restart: always  # Instead of unless-stopped
   ```

2. Enable Docker auto-start:
   - **Package Center** → **Docker** → Settings → Enable on boot

3. Create scheduled task in DSM:
   - **Control Panel** → **Task Scheduler**
   - Create boot-up task: `docker start openclaw`

---

## Diagnostic Commands

### Get Full Container Information
```bash
docker inspect openclaw
```

### View Real-time Logs
```bash
docker logs -f openclaw
```

### Check Container Resource Usage
```bash
docker stats openclaw
```

### List All Containers
```bash
docker ps -a
```

### Execute Command in Container
```bash
docker exec -it openclaw /bin/bash
```

### View Docker Network
```bash
docker network ls
docker network inspect bridge
```

---

## Getting Additional Help

If you've tried these solutions and still have issues:

1. **Gather Information**:
   ```bash
   docker logs openclaw > openclaw-logs.txt
   docker inspect openclaw > openclaw-inspect.txt
   docker --version > system-info.txt
   uname -a >> system-info.txt
   ```

2. **Check GitHub Issues**:
   - OpenClaw: https://github.com/pjasicek/OpenClaw/issues
   - This repository: Check issues tab

3. **Synology Community**:
   - Synology Community Forums
   - Reddit: r/synology

4. **Create New Issue**:
   - Include logs and system information
   - Describe steps to reproduce the problem
   - Mention Synology model and DSM version

---

## Prevention Tips

1. **Regular Backups**: Backup saves folder regularly
2. **Keep Updated**: Update Docker images periodically
3. **Monitor Resources**: Check resource usage in Resource Monitor
4. **Document Changes**: Keep notes of configuration changes
5. **Test Updates**: Test updates on non-production systems first

---

Last Updated: 2026-02-10
