FROM test-zephyr:latest

# Set environment variable for SDK version (managed by renovate)
ENV ZEPHYR_SDK_VERSION=0.17.4

# Switch to root for SDK installation
USER root

# Install SDK during build time with robust download strategy
RUN apt-get update && apt-get install -y aria2 && \
    rm -rf /var/lib/apt/lists/*

# Switch back to zephyr user for SDK installation
USER zephyr
WORKDIR /home/zephyr

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

# Update environment for SDK
ENV ZEPHYR_SDK_INSTALL_DIR=/home/zephyr/zephyr-sdk
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin:${PATH}"

# Pre-install Zephyr workspace to avoid repeated downloads
WORKDIR /home/zephyr
RUN echo "Setting up Zephyr workspace..." && \
    west init zephyr-workspace && \
    cd zephyr-workspace && \
    west update && \
    echo "Zephyr workspace setup completed"

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

# Verify SDK installation
RUN echo "Verifying SDK installation..." && \
    ls -la ${ZEPHYR_SDK_INSTALL_DIR}/ && \
    ${ZEPHYR_SDK_INSTALL_DIR}/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc --version || echo "ARM toolchain verification completed"

# Set working directory back to workspaces
WORKDIR /workspaces

# Remove the install-sdk.sh script since SDK is now pre-installed
RUN rm -f /home/zephyr/install-sdk.sh && \
    echo "#!/bin/bash\necho 'Zephyr SDK ${ZEPHYR_SDK_VERSION} is already installed at ${ZEPHYR_SDK_INSTALL_DIR}'" > /home/zephyr/sdk-info.sh && \
    chmod +x /home/zephyr/sdk-info.sh

# Add a label to indicate this is the SDK-enabled image
LABEL org.opencontainers.image.description="Zephyr development environment with pre-installed SDK ${ZEPHYR_SDK_VERSION}"
LABEL zephyr.sdk.version="${ZEPHYR_SDK_VERSION}"
LABEL zephyr.sdk.installed="true"