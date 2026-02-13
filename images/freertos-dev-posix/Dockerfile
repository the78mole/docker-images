# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential packages
RUN apt-get update && apt-get install -y \
    # Build tools
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    gdb \
    git \
    # Libraries for FreeRTOS POSIX port
    libc6-dev \
    libssl-dev \
    libmbedtls-dev \
    # Debugging and analysis tools
    valgrind \
    strace \
    # Network tools
    net-tools \
    iputils-ping \
    iproute2 \
    curl \
    tcpdump \
    # Additional utilities
    vim \
    nano \
    wget \
    tree \
    htop \
    sudo \
    ca-certificates \
    # Python for scripts
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user with sudo privileges
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Create directories for FreeRTOS
RUN mkdir -p /workspace/FreeRTOS-Kernel \
    && mkdir -p /workspace/FreeRTOS-Plus-TCP \
    && chown -R $USERNAME:$USERNAME /workspace

# Copy welcome message
COPY welcome.txt /home/$USERNAME/welcome.txt
RUN chown $USERNAME:$USERNAME /home/$USERNAME/welcome.txt

# Set working directory
WORKDIR /workspaces

# Switch to non-root user
USER $USERNAME

# Set environment variables
ENV FREERTOS_PATH=/workspace/FreeRTOS-Kernel
ENV FREERTOS_TCP_PATH=/workspace/FreeRTOS-Plus-TCP
ENV FREERTOS_PORT=GCC/Posix

# Add labels
LABEL org.opencontainers.image.description="FreeRTOS POSIX/Linux simulator development environment"
LABEL org.opencontainers.image.source="https://github.com/the78mole/docker-images"

CMD ["/bin/bash"]
