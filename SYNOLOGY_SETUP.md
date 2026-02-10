# Synology-Specific Setup Instructions

## Prerequisites for Synology NAS

1. **DSM Version**: 7.0 or higher recommended
2. **Docker Package**: Installed from Package Center
3. **CPU Architecture**: x86_64 (Intel/AMD) - ARM-based Synology NAS may require different build
4. **Available Storage**: At least 2GB free space

## Installation Steps for Synology

### Step 1: Prepare Directories

1. Open **File Station**
2. Navigate to a shared folder (e.g., `docker`)
3. Create a new folder: `openclaw`
4. Inside `openclaw`, create three folders:
   - `assets`
   - `config`
   - `saves`

### Step 2: Upload Files

1. Upload the following files to `/volume1/docker/openclaw/`:
   - `Dockerfile`
   - `docker-compose.yml`
   - `entrypoint.sh`
   - `.gitignore`

2. Upload your `CLAW.REZ` file to `/volume1/docker/openclaw/assets/`

### Step 3: Build Using Docker GUI

1. Open **Docker** app in DSM
2. Go to **Image** tab
3. Click **Add** → **Add from File**
4. Browse and select the `Dockerfile`
5. Wait for the build to complete (this may take 10-30 minutes)

### Step 4: Create Container via GUI

1. In Docker app, go to **Image** tab
2. Select `openclaw:latest`
3. Click **Launch**
4. In the wizard:
   - **General Settings**:
     - Container name: `openclaw`
     - Enable auto-restart: ✓
   
   - **Volume Settings**:
     - Add folder: `/docker/openclaw/assets` → Mount path: `/openclaw/ASSETS`
     - Add folder: `/docker/openclaw/config` → Mount path: `/openclaw/config`
     - Add folder: `/docker/openclaw/saves` → Mount path: `/openclaw/saves`
   
   - **Port Settings**:
     - Container Port: 8080 → Local Port: 8080 (if needed for web access)
   
   - **Environment**:
     - Add variable: `TZ` = Your timezone (e.g., `America/New_York`)

5. Click **Apply** and **Next** to create the container

### Step 5: Using SSH (Alternative/Advanced)

If you prefer using command line:

```bash
# Connect to your Synology
ssh admin@your-nas-ip

# Navigate to docker directory
cd /volume1/docker/openclaw

# Build the image
sudo docker build -t openclaw:latest .

# Run the container
sudo docker-compose up -d

# Check logs
sudo docker-compose logs -f openclaw
```

## Common Synology Issues

### Issue: Build fails on ARM architecture
**Solution**: This Dockerfile is designed for x86_64. ARM-based Synology NAS (like some Plus series) may need modifications to the Dockerfile.

### Issue: Permission denied errors
**Solution**: 
```bash
sudo chmod -R 777 /volume1/docker/openclaw
```

### Issue: Container restarts constantly
**Solution**: Check logs in Docker app or via command:
```bash
sudo docker logs openclaw
```

### Issue: Cannot access via SSH
**Solution**: 
1. Go to **Control Panel** → **Terminal & SNMP**
2. Enable SSH service
3. Connect using an SSH client (e.g., PuTTY, Terminal)

## Performance Tips

1. **Storage**: Use SSD cache if available for better performance
2. **Resources**: Allocate at least 1GB RAM to the container
3. **Network**: Use bridge mode for better isolation

## Backup Considerations

Save games are stored in `/volume1/docker/openclaw/saves/`. Include this in your Synology backup plan:

1. **Hyper Backup**: Add `/volume1/docker/openclaw/saves/` to backup task
2. **Snapshot Replication**: Include the docker shared folder

## Security Notes

1. **Firewall**: If exposing ports, configure DSM firewall rules
2. **Access Control**: Set appropriate permissions on the openclaw folder
3. **Updates**: Regularly update the Docker image and DSM

## Monitoring

Monitor container health in DSM:
1. Open **Docker** app
2. Go to **Container** tab
3. Check status of `openclaw` container
4. Click on container to view logs and performance

## Additional Resources

- Synology Docker documentation: https://www.synology.com/en-us/dsm/packages/Docker
- DSM Help: https://www.synology.com/en-us/support
