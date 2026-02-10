# Troubleshooting Checklist

Use this checklist to diagnose and resolve common issues with OpenClaw Docker on Synology.

## Before You Start

- [ ] Verify Docker is installed and running on Synology
- [ ] Confirm you have at least 2GB free RAM
- [ ] Check that port 18789 is not in use

## Installation Issues

### Docker Build Fails

- [ ] Check internet connectivity: `ping 8.8.8.8`
- [ ] Verify Docker service is running: `sudo synoservicectl --status pkgctl-Docker`
- [ ] Check available disk space: `df -h`
- [ ] Review build logs for specific errors
- [ ] Try building with `--no-cache` flag: `docker build --no-cache -t openclaw:latest .`

### Cannot Download npm Packages

- [ ] Test npm registry access: `curl -I https://registry.npmjs.org`
- [ ] Check DNS resolution: `nslookup registry.npmjs.org`
- [ ] Verify firewall allows outbound connections
- [ ] Try using alternative npm registry in Dockerfile

## Container Issues

### Container Won't Start

- [ ] Check container logs: `sudo docker logs openclaw-gateway`
- [ ] Verify configuration: `sudo docker compose config`
- [ ] Check for port conflicts: `sudo netstat -tulpn | grep 18789`
- [ ] Ensure data directories exist: `ls -la data/`
- [ ] Check permissions: `sudo chown -R 1000:1000 data/`
- [ ] Verify .env file exists and is properly formatted
- [ ] Try starting in foreground: `sudo docker compose up openclaw` (no -d flag)

### Container Starts But Crashes

- [ ] Check logs: `sudo docker compose logs openclaw`
- [ ] Verify API keys are valid in .env file
- [ ] Check memory limits are not too restrictive
- [ ] Ensure all required environment variables are set
- [ ] Try increasing startup timeout in health check

### Container Runs But Health Check Fails

- [ ] Manually test gateway: `curl http://localhost:18789`
- [ ] Check if gateway is actually listening: `sudo docker exec openclaw-gateway netstat -tlnp`
- [ ] Verify health check command: `sudo docker exec openclaw-gateway curl -f http://localhost:18789/`
- [ ] Increase health check start period in Dockerfile
- [ ] Review gateway logs for startup errors

## Connectivity Issues

### Cannot Access Gateway from Browser

- [ ] Verify container is running: `sudo docker ps | grep openclaw`
- [ ] Test from Synology: `curl http://localhost:18789`
- [ ] Test from your computer: `curl http://NAS_IP:18789`
- [ ] Check Synology firewall: Control Panel > Security > Firewall
- [ ] Verify port mapping in docker-compose.yml
- [ ] Try accessing via NAS IP instead of hostname
- [ ] Check if reverse proxy is interfering

### Cannot Access from Outside Network

- [ ] Verify port forwarding on router
- [ ] Check Synology firewall allows external connections
- [ ] Test with external IP: `curl http://EXTERNAL_IP:18789`
- [ ] Consider setting up reverse proxy with SSL
- [ ] Check ISP doesn't block the port

## API and Authentication Issues

### API Key Errors

- [ ] Verify API keys are correct in .env file
- [ ] Check for extra spaces or quotes around keys
- [ ] Ensure keys haven't expired
- [ ] Verify keys have necessary permissions
- [ ] Test keys with curl to API provider
- [ ] Try re-running onboarding wizard
- [ ] Restart container after changing keys: `sudo docker compose restart`

### Onboarding Wizard Fails

- [ ] Ensure container is running: `sudo docker ps`
- [ ] Check container has internet access
- [ ] Verify API provider services are online
- [ ] Try running wizard with verbose output
- [ ] Check logs during wizard: `sudo docker compose logs -f openclaw`

## Performance Issues

### Slow Response Times

- [ ] Check NAS CPU usage: Resource Monitor
- [ ] Check memory usage: `sudo docker stats openclaw-gateway`
- [ ] Verify no disk I/O bottleneck: `iostat -x 1`
- [ ] Increase memory limit in docker-compose.yml
- [ ] Allocate more CPU cores in docker-compose.yml
- [ ] Check network latency to API providers
- [ ] Consider upgrading NAS RAM

### High Memory Usage

- [ ] Monitor with: `sudo docker stats openclaw-gateway`
- [ ] Check for memory leaks in logs
- [ ] Restart container: `sudo docker compose restart`
- [ ] Reduce concurrent operations
- [ ] Increase swap space if available

### Container Consuming All CPU

- [ ] Check for infinite loops in logs
- [ ] Verify no stuck processes: `sudo docker exec openclaw-gateway ps aux`
- [ ] Restart container: `sudo docker compose restart`
- [ ] Check OpenClaw version for known issues
- [ ] Consider limiting CPU usage in docker-compose.yml

## Data and Persistence Issues

### Data Not Persisting After Restart

- [ ] Verify volume mappings: `sudo docker inspect openclaw-gateway`
- [ ] Check data directories exist: `ls -la data/`
- [ ] Ensure correct paths in docker-compose.yml
- [ ] Check directory permissions: `ls -la data/`
- [ ] Verify OPENCLAW_HOME environment variable

### Cannot Access Configuration Files

- [ ] Check config directory exists: `ls -la data/config/`
- [ ] Verify permissions: `sudo chown -R 1000:1000 data/config`
- [ ] Check OPENCLAW_CONFIG environment variable
- [ ] Try accessing from inside container: `sudo docker exec -it openclaw-gateway ls /data/config`

## Update and Maintenance Issues

### Update Fails

- [ ] Stop container before updating: `sudo docker compose down`
- [ ] Check available disk space: `df -h`
- [ ] Backup data before updating: `tar -czf backup.tar.gz data/`
- [ ] Pull latest base image: `docker pull node:22-alpine`
- [ ] Build with no cache: `docker compose build --no-cache`
- [ ] Check for breaking changes in OpenClaw release notes

### Backup Fails

- [ ] Ensure container is stopped: `sudo docker compose down`
- [ ] Check write permissions to backup location
- [ ] Verify sufficient disk space: `df -h`
- [ ] Test backup command: `tar -czf test.tar.gz data/`

## Synology-Specific Issues

### DSM UI Shows Container as Stopped

- [ ] Check actual status: `sudo docker ps -a | grep openclaw`
- [ ] Restart Docker service: `sudo synoservicectl --restart pkgctl-Docker`
- [ ] Refresh DSM web interface (Ctrl+F5)
- [ ] Check DSM logs: Log Center

### Cannot Create Container in DSM UI

- [ ] Verify Docker package is running
- [ ] Check DSM version compatibility (7.0+ recommended)
- [ ] Try using SSH and docker compose instead
- [ ] Review DSM Docker logs for errors
- [ ] Ensure sufficient privileges (admin user)

### File Permission Errors on Synology

- [ ] Check owner: `ls -la data/`
- [ ] Fix permissions: `sudo chown -R 1000:1000 data/`
- [ ] Verify shared folder permissions in DSM
- [ ] Check if folder is encrypted or mounted

## Getting Help

If you've tried everything on this checklist:

1. **Gather Information:**
   ```bash
   # Save container info
   sudo docker inspect openclaw-gateway > container-info.txt
   
   # Save logs
   sudo docker compose logs openclaw > container-logs.txt
   
   # Save config
   sudo docker compose config > compose-config.txt
   
   # System info
   uname -a > system-info.txt
   df -h > disk-info.txt
   free -h > memory-info.txt
   ```

2. **Check Resources:**
   - [README.md](README.md) - Main documentation
   - [SYNOLOGY_GUIDE.md](SYNOLOGY_GUIDE.md) - Detailed guide
   - [OpenClaw Docs](https://docs.openclaw.ai)
   - [OpenClaw Discord](https://discord.gg/clawd)

3. **Report Issue:**
   - Create GitHub issue with gathered information
   - Include Synology model and DSM version
   - Describe steps to reproduce
   - Attach relevant logs (redact sensitive info)

## Common Error Messages

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `permission denied` | File permissions | Run `sudo chown -R 1000:1000 data/` |
| `port already in use` | Port conflict | Check with `netstat -tulpn \| grep 18789` |
| `no space left on device` | Disk full | Free up space or increase storage |
| `cannot connect to docker daemon` | Docker not running | Start Docker service |
| `image not found` | Build didn't complete | Re-run `./build.sh` |
| `health check failed` | Gateway not starting | Check logs with `docker logs openclaw-gateway` |
| `API key invalid` | Wrong or expired key | Update .env and restart |
| `network timeout` | Internet/firewall issue | Check connectivity and firewall |

## Quick Diagnostics Script

Run this to gather diagnostic information:

```bash
#!/bin/bash
echo "=== OpenClaw Docker Diagnostics ==="
echo ""
echo "System Info:"
uname -a
echo ""
echo "Docker Version:"
docker --version
echo ""
echo "Container Status:"
sudo docker ps -a | grep openclaw
echo ""
echo "Container Logs (last 50 lines):"
sudo docker logs --tail 50 openclaw-gateway
echo ""
echo "Port Status:"
sudo netstat -tulpn | grep 18789
echo ""
echo "Disk Space:"
df -h | grep volume1
echo ""
echo "Memory:"
free -h
echo ""
echo "=== End Diagnostics ==="
```

Save as `diagnostics.sh`, make executable with `chmod +x diagnostics.sh`, and run with `./diagnostics.sh`.
