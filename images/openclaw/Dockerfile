FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create user with specific UID/GID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Clone OpenClaw repository
RUN git clone https://github.com/openclaw/openclaw.git /opt/openclaw && \
    chown -R $USERNAME:$USERNAME /opt/openclaw

# Switch to user
USER $USERNAME
WORKDIR /opt/openclaw

# Install OpenClaw dependencies
RUN npm install

# Create directory for OpenClaw data
RUN mkdir -p /home/$USERNAME/.openclaw/workspace

# Expose ports
# 18789 - OpenClaw Control UI
EXPOSE 18789

# Set up environment
ENV OPENCLAW_HOME=/home/$USERNAME/.openclaw

# Default command runs the gateway
CMD ["npm", "run", "gateway", "start", "--", "--foreground"]
