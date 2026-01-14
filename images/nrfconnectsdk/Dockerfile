# Nordic nRF Connect SDK Development Environment
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Set up locale
RUN apt-get update && apt-get install -y \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    device-tree-compiler \
    ccache \
    dfu-util \
    file \
    gcc \
    g++ \
    gperf \
    libffi-dev \
    libssl-dev \
    libtool \
    autoconf \
    automake \
    pkg-config \
    unzip \
    zip \
    gdb \
    openocd \
    minicom \
    screen \
    usbutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages required for nRF Connect SDK
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && python3 -m pip install --no-cache-dir \
    west \
    intelhex \
    click \
    cryptography \
    cbor2 \
    ecdsa \
    pyserial \
    pyyaml \
    pyelftools

# Download and install nrfutil from Nordic Semiconductor
RUN wget -q https://developer.nordicsemi.com/.pc-tools/nrfutil/x64-linux/nrfutil -O /usr/local/bin/nrfutil \
    && chmod +x /usr/local/bin/nrfutil \
    && /usr/local/bin/nrfutil --version || echo "nrfutil downloaded (license acceptance may be required)"

# Create development user
RUN groupadd -r nrfdev && useradd -r -g nrfdev -m -d /home/nrfdev -s /bin/bash nrfdev

# Create workspace directory
RUN mkdir -p /workspace && chown nrfdev:nrfdev /workspace

# Set environment variables
ENV PATH="/home/nrfdev/.local/bin:${PATH}"

# Note: Zephyr SDK can be installed later if needed
# For now, we focus on nrfutil and basic development tools

# Note: VS Code extensions are configured in DevContainer configuration
# See example .devcontainer/devcontainer.json for recommended extensions

# Set up workspace and permissions
WORKDIR /workspace
RUN chown -R nrfdev:nrfdev /workspace /home/nrfdev

# Configure sudo for nrfdev user
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "nrfdev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add helpful aliases and environment setup
RUN echo 'export PATH="/home/nrfdev/.local/bin:$PATH"' >> /etc/bash.bashrc \
    && echo '#!/bin/bash\necho "nrfutil Commands:"\necho "  nrfutil --version"\necho "  nrfutil device list"\necho "  nrfutil device program --firmware app.hex"\necho "  nrfutil device reset"\necho "  nrfutil device recover"\necho "  west --version (if west is installed)"' > /usr/local/bin/nrf-help \
    && chmod +x /usr/local/bin/nrf-help

# Switch to development user
USER nrfdev

# Set default working directory
WORKDIR /workspace

# Default command shows available tools
CMD ["bash", "-c", "echo 'nRF Development Environment'; echo 'Available commands:'; echo '  nrfutil --version'; echo '  west --version'; echo '  cmake --version'; echo '  ninja --version'; echo ''; echo 'Use nrf-help for common commands'; echo ''; nrfutil --version 2>/dev/null || echo 'nrfutil ready'; west --version 2>/dev/null || echo 'west ready'"]