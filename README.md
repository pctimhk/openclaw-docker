# OpenClaw Docker for Synology

Docker container setup for running OpenClaw on Synology NAS systems.

## About OpenClaw

OpenClaw is an open-source reimplementation of Captain Claw (1997), a classic 2D platformer game. This Docker container allows you to run OpenClaw on your Synology NAS.

## Prerequisites

1. **Synology NAS** with Docker package installed
2. **Original Captain Claw game files** (specifically CLAW.REZ) - You must own the original game
3. SSH access to your Synology NAS (optional, for command-line setup)

## Quick Start for Synology

### Option 1: Using Docker Compose (Recommended)

1. **Enable SSH** on your Synology NAS (Control Panel > Terminal & SNMP)

2. **Connect to your NAS via SSH:**
   ```bash
   ssh your-username@your-nas-ip
   ```

3. **Navigate to a shared folder** (e.g., docker):
   ```bash
   cd /volume1/docker
   mkdir openclaw
   cd openclaw
   ```

4. **Clone or download this repository:**
   ```bash
   git clone https://github.com/pctimhk/openclaw-docker.git .
   ```
   
   Or download the files manually via File Station.

5. **Copy your CLAW.REZ file** to the `assets` directory:
   ```bash
   cp /path/to/your/CLAW.REZ ./assets/
   ```

6. **Build and run the container:**
   ```bash
   docker-compose up -d
   ```

### Option 2: Using Synology Docker GUI

1. **Open Docker app** in DSM

2. **Registry**: Search for a base Ubuntu image (if you want to use a pre-built image, skip to step 4)

3. **Build the image**:
   - Go to "Image" tab
   - Click "Add" > "Add from file"
   - Upload the Dockerfile and related files

4. **Create a container**:
   - Select the openclaw image
   - Click "Launch"
   - Configure the container:
     - Container Name: `openclaw`
     - Enable auto-restart
   
5. **Configure Volumes**:
   - Add volume: `/volume1/docker/openclaw/assets` → `/openclaw/ASSETS`
   - Add volume: `/volume1/docker/openclaw/config` → `/openclaw/config`
   - Add volume: `/volume1/docker/openclaw/saves` → `/openclaw/saves`

6. **Place your game files**:
   - Copy `CLAW.REZ` to `/volume1/docker/openclaw/assets/` using File Station

## Directory Structure

```
openclaw-docker/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── entrypoint.sh          # Container startup script
├── assets/                # Place CLAW.REZ here
├── config/                # Configuration files
├── saves/                 # Save game files
└── README.md              # This file
```

## Configuration

### Environment Variables

You can customize the container using environment variables in `docker-compose.yml`:

- `DISPLAY`: X11 display for GUI output (default: `:0`)
- `TZ`: Timezone (default: `UTC`)

### Volume Mounts

- `./assets:/openclaw/ASSETS` - Game assets (CLAW.REZ file)
- `./config:/openclaw/config` - Configuration files
- `./saves:/openclaw/saves` - Save game files

## Building the Image

To build the Docker image manually:

```bash
docker build -t openclaw:latest .
```

## Running the Container

### Using Docker Compose:
```bash
docker-compose up -d
```

### Using Docker CLI:
```bash
docker run -d \
  --name openclaw \
  --restart unless-stopped \
  -v $(pwd)/assets:/openclaw/ASSETS \
  -v $(pwd)/config:/openclaw/config \
  -v $(pwd)/saves:/openclaw/saves \
  openclaw:latest
```

## Accessing the Game

Since OpenClaw is a graphical game, you'll need to set up X11 forwarding or VNC to access the GUI:

1. **VNC Method** (Recommended for Synology):
   - Install a VNC server in the container or use a VNC-enabled base image
   - Connect using a VNC client

2. **X11 Forwarding**:
   - Requires X server on your client machine
   - Configure DISPLAY variable

## Troubleshooting

### Container won't start
- Check logs: `docker-compose logs openclaw`
- Verify CLAW.REZ is in the assets directory

### Game files not found
- Ensure CLAW.REZ is copied to the `assets` folder
- Check volume mount permissions

### Permission issues
- On Synology, ensure the Docker user has access to the mounted folders
- Try: `sudo chmod -R 777 /volume1/docker/openclaw/assets`

## Updating

To update to the latest version:

```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

## Legal Notice

You must own a legal copy of Captain Claw to use the game assets (CLAW.REZ). This Docker container only provides the OpenClaw engine, which is open source. The original game assets are copyrighted and not included.

## Credits

- **OpenClaw Project**: https://github.com/pjasicek/OpenClaw
- **Captain Claw**: Original game by Monolith Productions (1997)

## License

This Docker configuration is provided as-is. OpenClaw is under its own license. Please refer to the OpenClaw repository for details.

## Support

For issues specific to this Docker setup, please open an issue on this repository.
For OpenClaw game issues, refer to the official OpenClaw repository.
