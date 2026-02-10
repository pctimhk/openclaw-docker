# OpenClaw Docker Image for Synology
# Based on Node.js 22 Alpine for smaller image size
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

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
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:18789/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Default command - run gateway
CMD ["openclaw", "gateway", "--port", "18789", "--verbose"]
