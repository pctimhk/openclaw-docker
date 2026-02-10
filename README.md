# OpenClaw Docker for Synology NAS

Run [OpenClaw](https://github.com/OpenClaw/OpenClaw), a personal AI assistant, on your Synology NAS using Docker.

## Features

- 🐳 Optimized Docker image based on Alpine Linux (small footprint)
- 🔄 Automatic restart on failure
- 💾 Persistent data storage with volume mappings
- ⚙️ Easy configuration through environment variables
- 🏥 Built-in health checks
- 📊 Resource limits for Synology NAS compatibility

## Prerequisites

- Synology NAS with Docker package installed (DSM 7.0 or higher recommended)
- At least 2GB of available RAM
- Basic understanding of Docker and command line
- API keys from OpenAI or Anthropic (for AI functionality)

## Quick Start on Synology

### Option 1: Using Docker Compose (Recommended)

1. **Enable SSH** on your Synology NAS (Control Panel > Terminal & SNMP > Enable SSH service)

2. **Connect via SSH** to your Synology NAS:
   ```bash
   ssh your-username@your-nas-ip
   ```

3. **Create a directory** for OpenClaw:
   ```bash
   mkdir -p /volume1/docker/openclaw
   cd /volume1/docker/openclaw
   ```

4. **Copy the files** from this repository to the directory:
   - `Dockerfile`
   - `docker-compose.yml`
   - `.env.example` (rename to `.env`)

5. **Configure environment variables**:
   ```bash
   cp .env.example .env
   nano .env
   ```
   Edit the `.env` file and add your API keys and preferences.

6. **Build and start the container**:
   ```bash
   sudo docker-compose up -d
   ```

7. **Check the logs**:
   ```bash
   sudo docker-compose logs -f openclaw
   ```

8. **Access OpenClaw gateway** at `http://your-nas-ip:18789`

### Option 2: Using Synology Docker UI

1. **Open Docker package** on your Synology DSM

2. **Go to Registry** and search for "node" (or build image manually)

3. **Go to Image** and import the built image

4. **Launch Container** with these settings:
   - **Container Name**: openclaw-gateway
   - **Port Settings**: Map Local Port `18789` to Container Port `18789`
   - **Volume Settings**: 
     - Mount `/volume1/docker/openclaw/data` to `/data/openclaw`
     - Mount `/volume1/docker/openclaw/config` to `/data/config`
   - **Environment Variables**: Add API keys and configuration
   - **Resource Limitation**: Set memory limit to 2GB, CPU to 2 cores

5. **Start the container**

## Configuration

### Environment Variables

Key environment variables you can configure:

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Node environment | `production` |
| `OPENCLAW_HOME` | Data directory | `/data/openclaw` |
| `OPENCLAW_CONFIG` | Config directory | `/data/config` |
| `GATEWAY_PORT` | Gateway port | `18789` |
| `TZ` | Timezone | `UTC` |
| `LOG_LEVEL` | Log level (debug/info/warn/error) | `info` |
| `ANTHROPIC_API_KEY` | Anthropic API key | - |
| `OPENAI_API_KEY` | OpenAI API key | - |

### Volume Mappings

- `/data/openclaw` - OpenClaw data and workspace
- `/data/config` - Configuration files

### Port Mappings

- `18789` - OpenClaw gateway (default)

## Initial Setup

After starting the container for the first time, you'll need to run the onboarding wizard:

```bash
# Access the container shell
sudo docker exec -it openclaw-gateway sh

# Run the onboarding wizard
openclaw onboard

# Exit the container
exit
```

Follow the wizard to:
1. Set up your AI model preferences (Anthropic/OpenAI)
2. Configure communication channels (WhatsApp, Telegram, Slack, etc.)
3. Set up skills and capabilities

## Usage

### Sending Messages

```bash
# From outside the container
sudo docker exec -it openclaw-gateway openclaw message send --to +1234567890 --message "Hello"

# From inside the container
sudo docker exec -it openclaw-gateway sh
openclaw message send --to +1234567890 --message "Hello"
```

### Talking to the Assistant

```bash
sudo docker exec -it openclaw-gateway openclaw agent --message "Ship checklist" --thinking high
```

### Checking Status

```bash
# View logs
sudo docker-compose logs -f openclaw

# Check container status
sudo docker-compose ps

# Check health
sudo docker inspect openclaw-gateway | grep -A 10 Health
```

## Updating

To update to the latest version of OpenClaw:

```bash
cd /volume1/docker/openclaw
sudo docker-compose down
sudo docker-compose pull
sudo docker-compose build --no-cache
sudo docker-compose up -d
```

Or update within the container:

```bash
sudo docker exec -it openclaw-gateway npm update -g openclaw@latest
sudo docker-compose restart openclaw
```

## Troubleshooting

### Container won't start

1. Check logs: `sudo docker-compose logs openclaw`
2. Verify port 18789 is not in use: `sudo netstat -tulpn | grep 18789`
3. Check file permissions on volume directories
4. Ensure sufficient resources (RAM/CPU) are available

### Cannot connect to gateway

1. Verify container is running: `sudo docker-compose ps`
2. Check firewall rules on Synology
3. Verify port mapping is correct
4. Check health status: `sudo docker inspect openclaw-gateway`

### Performance issues

1. Increase memory limit in `docker-compose.yml`
2. Allocate more CPU cores
3. Check Synology NAS resource usage
4. Review logs for errors

### API key issues

1. Verify API keys are correctly set in `.env` file
2. Restart container after changing environment variables
3. Run onboarding wizard to reconfigure

## Resource Requirements

### Minimum
- RAM: 512MB
- CPU: 1 core
- Storage: 1GB

### Recommended
- RAM: 2GB
- CPU: 2 cores
- Storage: 5GB

## Security Considerations

- Keep your API keys secure (use `.env` file, never commit to git)
- Restrict access to the gateway port (use Synology firewall)
- Regularly update the OpenClaw image
- Use strong passwords for any authentication
- Consider using reverse proxy with SSL/TLS for external access

## Additional Resources

- [OpenClaw Official Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub Repository](https://github.com/OpenClaw/OpenClaw)
- [OpenClaw Discord Community](https://discord.gg/clawd)
- [Synology Docker Documentation](https://www.synology.com/en-us/dsm/packages/Docker)

## Support

For issues specific to this Docker setup, please open an issue in this repository.

For OpenClaw-related questions, visit the [OpenClaw Discord](https://discord.gg/clawd) or [GitHub](https://github.com/OpenClaw/OpenClaw).

## License

This Docker setup is provided as-is. OpenClaw is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
