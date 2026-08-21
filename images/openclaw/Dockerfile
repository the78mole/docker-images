FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    sudo \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x using official binaries with SHA256 verification
RUN wget https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-x64.tar.xz && \
    echo "22982235e1b71fa8850f82edd09cdae7e3f32df1764a9ec298c72d25ef2c164f  node-v22.12.0-linux-x64.tar.xz" | sha256sum -c - && \
    tar -xJf node-v22.12.0-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    rm node-v22.12.0-linux-x64.tar.xz

# Install pnpm using npm (which comes with Node.js)
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
