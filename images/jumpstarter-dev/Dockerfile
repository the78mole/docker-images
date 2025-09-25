# Jumpstarter Development Environment Docker Image

FROM mcr.microsoft.com/devcontainers/base:ubuntu

LABEL maintainer="the78mole"
LABEL description="Complete Jumpstarter development environment with Docker-in-Docker, Kind, and all necessary tools"
LABEL version="1.0.0"

# System update and essential packages including DinD requirements
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    netcat-openbsd \
    telnet \
    iputils-ping \
    dnsutils \
    net-tools \
    python3 \
    python3-pip \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    lsb-release \
    pigz \
    iptables \
    dirmngr \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CE (for Docker-in-Docker) using official installation method
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Setup Docker group and add user
RUN groupadd -f docker \
    && usermod -aG docker vscode \
    && usermod -aG docker root

# Switch to legacy iptables for compatibility
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy || true \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true

# Install kubectl (latest stable)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/bin/kubectl \
    && ln -sf /usr/bin/kubectl /usr/local/bin/kubectl

# Install Helm (latest)
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && mv /usr/local/bin/helm /usr/bin/helm \
    && ln -sf /usr/bin/helm /usr/local/bin/helm

# Install Kind v0.20.0 (specific version as per jumpstarter-dev-env)
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

# Install k9s (Kubernetes dashboard)
RUN curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz \
    && tar -xzf k9s.tar.gz \
    && mv k9s /usr/local/bin/k9s \
    && rm k9s.tar.gz

# Install UV (fast Python package manager) - system-wide installation
RUN curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx \
    && chmod +x /usr/local/bin/uv /usr/local/bin/uvx

# Install Robot Framework and dependencies globally
RUN pip3 install --no-cache-dir --break-system-packages \
    robotframework==7.0 \
    robotframework-requests==0.9.6 \
    robotframework-browser==18.6.3 \
    requests \
    PyYAML \
    && rm -rf /root/.cache/pip

# Create workspace directory and setup
RUN mkdir -p /workspace /home/jumpstarter/.kube

# Set working directory
WORKDIR /workspace

# Copy setup script
COPY setup-jumpstarter.sh /usr/local/bin/setup-jumpstarter.sh
RUN chmod +x /usr/local/bin/setup-jumpstarter.sh

# Copy Kind configuration
COPY kind-config.yaml /etc/kind-config.yaml

# Copy Python project configuration
COPY pyproject.toml /workspace/pyproject.toml

# Copy and setup Docker-in-Docker init script
COPY docker-init.sh /usr/local/share/docker-init.sh
RUN chmod +x /usr/local/share/docker-init.sh \
    && chown vscode:root /usr/local/share/docker-init.sh

# Copy DevContainer initialization script
COPY .devcontainer/init-devcontainer.sh /usr/local/bin/init-devcontainer.sh
RUN chmod +x /usr/local/bin/init-devcontainer.sh

# Create entrypoint script that uses Docker-in-Docker init
RUN echo '#!/bin/bash\nset -e\n\necho "🚀 Jumpstarter Development Environment"\necho "===================================="\necho "Docker version: $(docker --version 2>/dev/null || echo \\"Docker not started\\")"\necho "kubectl version: $(kubectl version --client --short 2>/dev/null || echo \\"kubectl installed\\")"\necho "Helm version: $(helm version --short 2>/dev/null || echo \\"helm installed\\")"\necho "Kind version: $(kind version 2>/dev/null || echo \\"kind installed\\")"\necho "UV version: $(uv --version 2>/dev/null || echo \\"uv installed\\")"\necho "Working directory: $(pwd)"\necho ""\necho "Available commands:"\necho "  setup-jumpstarter.sh  # Complete Jumpstarter setup with Kind + Helm"\necho "  make dev              # Run complete development setup (if Makefile exists)"\necho "  kind create cluster   # Create Kind cluster manually"\necho "  kubectl get nodes     # Check cluster status"\necho "  k9s                   # Kubernetes dashboard"\necho "  uv --help            # Python package manager"\necho ""\necho "Example workflow:"\necho "  1. setup-jumpstarter.sh"\necho "  2. kubectl get pods -n jumpstarter-lab"\necho "  3. k9s -n jumpstarter-lab"\necho ""\n\n# Initialize Docker-in-Docker if running with privileged mode\nif [ "$(id -u)" = "0" ] && [ -f "/usr/local/share/docker-init.sh" ]; then\n    echo "🐳 Initializing Docker-in-Docker..."\n    exec /usr/local/share/docker-init.sh "$@"\nelse\n    echo "⚠️  Running without Docker-in-Docker init (not privileged or init script missing)"\n    # If arguments provided, execute them, otherwise start bash\n    if [ $# -eq 0 ]; then\n        exec bash\n    else\n        exec "$@"\n    fi\nfi' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Set environment variables
ENV WORKSPACE_DIR=/workspace
ENV KUBECONFIG=/home/jumpstarter/.kube/config
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/vscode/.local/bin:/root/.local/bin"

# Define volumes for data persistence
VOLUME ["/workspace", "/var/lib/docker"]

# Expose common ports for Jumpstarter services
EXPOSE 30010 30011 8080 8081 8082 8083 5080 9090

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]