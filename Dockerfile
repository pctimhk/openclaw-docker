# OpenClaw Docker Image for Synology
# Based on Node.js 22 Alpine for smaller image size
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install necessary build dependencies, curl for health checks, and OpenVPN for Surfshark support
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl \
    openvpn \
    wget \
    iptables \
    iproute2

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Create directories for persistent data
RUN mkdir -p /data/openclaw /data/config

# Set environment variables
ENV NODE_ENV=production
ENV OPENCLAW_HOME=/data/openclaw
ENV OPENCLAW_CONFIG=/data/config

# Expose default gateway port
EXPOSE 18789

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Volume for persistent data
VOLUME ["/data/openclaw", "/data/config"]

# Health check
# Note: Basic connectivity check to ensure gateway is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:18789/ || exit 1

# Set entrypoint to handle VPN connection
ENTRYPOINT ["/entrypoint.sh"]

# Default command - run gateway
CMD ["openclaw", "gateway", "--port", "18789", "--verbose"]
