FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x from NodeSource
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm globally (OpenClaw uses pnpm, not npm)
RUN npm install -g pnpm@10.23.0

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

# Install OpenClaw dependencies using pnpm
RUN pnpm install

# Create directory for OpenClaw data
RUN mkdir -p /home/ubuntu/.openclaw/workspace

# Expose ports
# 18789 - OpenClaw Control UI
EXPOSE 18789

# Set up environment
ENV OPENCLAW_HOME=/home/ubuntu/.openclaw

# Default command runs the gateway
CMD ["pnpm", "run", "gateway", "start", "--", "--foreground"]
