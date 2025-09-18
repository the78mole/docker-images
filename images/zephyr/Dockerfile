FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/home/zephyr/zephyr-sdk
ENV ZEPHYR_BASE=/workspaces/zephyr
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin:${PATH}"

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
ENV ZEPHYR_SDK_INSTALL_DIR=/home/zephyr/zephyr-sdk
WORKDIR /home/zephyr

# Create placeholder for Zephyr SDK (will be installed later)
RUN echo "Zephyr SDK will be installed on first container run" > /home/zephyr/zephyr-sdk/README.txt

# Setup script for Zephyr SDK (will run at runtime)
RUN echo '#!/bin/bash\n\
SDK_VERSION="0.17.4"\n\
SDK_FILE="zephyr-sdk-${SDK_VERSION}_linux-x86_64.tar.xz"\n\
\n\
if [ ! -f "/home/zephyr/zephyr-sdk/setup.sh" ]; then\n\
    echo "Downloading Zephyr SDK ${SDK_VERSION}..."\n\
    cd /home/zephyr\n\
    curl -L --retry 3 --retry-delay 30 --connect-timeout 60 --max-time 3600 \\\n\
    "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/${SDK_FILE}" \\\n\
    -o "${SDK_FILE}"\n\
    \n\
    echo "Extracting SDK..."\n\
    tar xf "${SDK_FILE}"\n\
    mv zephyr-sdk-${SDK_VERSION}/* zephyr-sdk/\n\
    rmdir zephyr-sdk-${SDK_VERSION}\n\
    rm "${SDK_FILE}"\n\
    \n\
    echo "Setting up SDK..."\n\
    cd /home/zephyr/zephyr-sdk\n\
    ./setup.sh -t all -h -c\n\
    echo "Zephyr SDK installation completed!"\n\
else\n\
    echo "Zephyr SDK already installed."\n\
fi' > /home/zephyr/install-sdk.sh && \
    chmod +x /home/zephyr/install-sdk.sh

# Install UV (modern Python package manager) and West as user
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    export PATH="/home/zephyr/.local/bin:${PATH}" && \
    uv tool install west && \
    uv tool install pyocd
ENV PATH="/home/zephyr/.local/bin:${PATH}"

# Create temporary Zephyr project to install Python dependencies using UV
RUN export PATH="/home/zephyr/.local/bin:${PATH}" && \
    mkdir -p /tmp/zephyr-temp && \
    cd /tmp/zephyr-temp && \
    west init -m https://github.com/zephyrproject-rtos/zephyr && \
    west update && \
    uv pip install --python ~/.local/share/uv/tools/west/bin/python \
        -r zephyr/scripts/requirements.txt && \
    rm -rf /tmp/zephyr-temp

# Set working directory
WORKDIR /workspaces

# Copy entrypoint script
COPY --chown=zephyr:zephyr entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER zephyr

# Set up workspace initialization script
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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]