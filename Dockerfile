# OpenClaw Docker for Synology
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    OPENCLAW_VERSION=master

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libsdl2-dev \
    libsdl2-mixer-dev \
    libsdl2-image-dev \
    libsdl2-ttf-dev \
    zlib1g-dev \
    libtinyxml-dev \
    libpng-dev \
    libfreetype6-dev \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /openclaw

# Clone OpenClaw repository
RUN git clone https://github.com/pjasicek/OpenClaw.git /openclaw-src

# Build OpenClaw
WORKDIR /openclaw-src/Build_Release
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    cp openclaw /openclaw/ && \
    cp -r ../Build_Release/Release/* /openclaw/ || true

# Copy assets directory structure
RUN mkdir -p /openclaw/ASSETS

# Set working directory
WORKDIR /openclaw

# Create a volume for game assets
VOLUME ["/openclaw/ASSETS"]

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port for potential web-based access
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./openclaw"]
