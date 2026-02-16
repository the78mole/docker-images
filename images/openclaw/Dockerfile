FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Node.js from Ubuntu repos
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    sudo \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Configure the ubuntu user (UID/GID 1000) for sudo access
# Ubuntu 24.04 containers include an ubuntu user by default
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# Clone OpenClaw repository and set ownership to ubuntu user
RUN git clone https://github.com/openclaw/openclaw.git /opt/openclaw && \
    chown -R ubuntu:ubuntu /opt/openclaw

# Switch to ubuntu user
USER ubuntu
WORKDIR /opt/openclaw

# Install OpenClaw dependencies
RUN npm install

# Create directory for OpenClaw data
RUN mkdir -p /home/ubuntu/.openclaw/workspace

# Expose ports
# 18789 - OpenClaw Control UI
EXPOSE 18789

# Set up environment
ENV OPENCLAW_HOME=/home/ubuntu/.openclaw

# Default command runs the gateway
CMD ["npm", "run", "gateway", "start", "--", "--foreground"]
