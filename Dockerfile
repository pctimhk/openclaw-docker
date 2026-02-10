# OpenClaw Docker Image for Synology
# Based on Node.js 22 Alpine for smaller image size
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install necessary build dependencies and curl for health checks
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl

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

# Volume for persistent data
VOLUME ["/data/openclaw", "/data/config"]

# Health check
# Note: Basic connectivity check to ensure gateway is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:18789/ || exit 1

# Default command - run gateway
CMD ["openclaw", "gateway", "--port", "18789", "--verbose"]
