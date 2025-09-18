FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/home/zephyr/zephyr-sdk
ENV ZEPHYR_BASE=/workspaces/zephyr
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin:${PATH}"

# Set environment variable for SDK version (managed by renovate)
ENV ZEPHYR_SDK_VERSION=0.17.4

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials (from INSTRUCTIONS.md)
    build-essential \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    wget \
    curl \
    # Download tools for robust SDK download
    aria2 \
    # Python and development tools
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-tk \
    python3-wheel \
    # USB support for flash tools (from INSTRUCTIONS.md)
    libusb-1.0-0-dev \
    # Additional tools
    xz-utils \
    file \
    make \
    gcc \
    gcc-multilib \
    g++-multilib \
    libsdl2-dev \
    libmagic1 \
    # Git and version control
    git \
    # USB and hardware tools
    udev \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create workspace directory and zephyr-sdk directory
RUN mkdir -p /workspaces /home/zephyr/zephyr-sdk

# Create a non-root user for development
RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 zephyr && \
    usermod -aG dialout zephyr && \
    chown -R zephyr:zephyr /workspaces /home/zephyr

# Switch to non-root user
USER zephyr
ENV HOME=/home/zephyr
WORKDIR /home/zephyr

# Install UV (modern Python package manager) first
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/zephyr/.local/bin:${PATH}"

# Install West and PyOCD using UV
RUN uv tool install west && \
    uv tool install pyocd

# Download and install Zephyr SDK with aria2 (more robust for large files)
RUN echo "Downloading Zephyr SDK ${ZEPHYR_SDK_VERSION}..." && \
    aria2c -x 8 -s 8 --max-tries=5 --retry-wait=30 \
        --timeout=300 --max-connection-per-server=8 \
        -o "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" \
        "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" && \
    echo "Extracting SDK..." && \
    tar xf "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" && \
    mv "zephyr-sdk-${ZEPHYR_SDK_VERSION}"/* zephyr-sdk/ && \
    rmdir "zephyr-sdk-${ZEPHYR_SDK_VERSION}" && \
    rm "zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz" && \
    echo "SDK extracted successfully"

# Setup Zephyr SDK
RUN cd ${ZEPHYR_SDK_INSTALL_DIR} && \
    ./setup.sh -t all -h -c && \
    echo "Zephyr SDK setup completed"

# Initialize Zephyr workspace (separate layer for better caching)
RUN echo "Initializing Zephyr workspace..." && \
    west init zephyr-workspace && \
    echo "Zephyr workspace initialized"

# Download Zephyr sources (separate layer - this is the largest part)
RUN echo "Downloading Zephyr sources..." && \
    cd zephyr-workspace && \
    west update && \
    echo "Cleaning up temporary files..." && \
    find . -name "*.pyc" -delete && \
    find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*.log" -delete && \
    find . -name "build" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name ".tmp*" -delete 2>/dev/null || true && \
    echo "Zephyr sources downloaded and cleaned"

# Install Python dependencies using UV with the downloaded Zephyr
RUN cd /home/zephyr/zephyr-workspace && \
    uv pip install --python ~/.local/share/uv/tools/west/bin/python \
        -r zephyr/scripts/requirements.txt && \
    uv cache clean && \
    echo "Python dependencies installed and cache cleaned"

# Create a script to create workspace with symlinks for new projects
RUN echo '#!/bin/bash\n\
if [ $# -eq 0 ]; then\n\
    echo "Usage: $0 <target-directory>"\n\
    echo "Creates a new Zephyr workspace with symlinks to pre-downloaded sources"\n\
    exit 1\n\
fi\n\
\n\
TARGET_DIR="$1"\n\
SOURCE_DIR="/home/zephyr/zephyr-workspace"\n\
\n\
if [ -d "$TARGET_DIR" ]; then\n\
    echo "Error: Target directory $TARGET_DIR already exists"\n\
    exit 1\n\
fi\n\
\n\
echo "Creating Zephyr workspace with symlinks at $TARGET_DIR..."\n\
mkdir -p "$TARGET_DIR"\n\
cd "$TARGET_DIR"\n\
\n\
# Create symlinks to all workspace components\n\
ln -s "$SOURCE_DIR/zephyr" zephyr\n\
ln -s "$SOURCE_DIR/modules" modules\n\
ln -s "$SOURCE_DIR/tools" tools\n\
ln -s "$SOURCE_DIR/bootloader" bootloader\n\
\n\
# Copy west configuration (needs to be writable)\n\
cp -r "$SOURCE_DIR/.west" .\n\
\n\
echo "Workspace created successfully at $TARGET_DIR"\n\
echo "You can now use: cd $TARGET_DIR && west build -b <board> <sample>"' > /home/zephyr/create-workspace.sh && \
    chmod +x /home/zephyr/create-workspace.sh

# Legacy workspace initialization script for compatibility
RUN echo '#!/bin/bash\n\
if [ ! -d "/workspaces/zephyr" ]; then\n\
    echo "Initializing Zephyr workspace..."\n\
    cd /workspaces\n\
    west init -m https://github.com/zephyrproject-rtos/zephyr\n\
    west update\n\
    echo "Zephyr workspace initialized!"\n\
else\n\
    echo "Zephyr workspace already exists."\n\
fi' > /home/zephyr/init-workspace.sh && \
    chmod +x /home/zephyr/init-workspace.sh

# Set working directory
WORKDIR /workspaces

# Copy entrypoint script
COPY --chown=zephyr:zephyr entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER zephyr

# Add labels
LABEL org.opencontainers.image.description="Zephyr development environment with pre-installed SDK ${ZEPHYR_SDK_VERSION}"
LABEL zephyr.sdk.version="${ZEPHYR_SDK_VERSION}"
LABEL zephyr.sdk.installed="true"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]