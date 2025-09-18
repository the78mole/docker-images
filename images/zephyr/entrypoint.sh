#!/bin/bash

# Zephyr Development Environment Entrypoint Script

# Set up environment variables
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk
export PATH="${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin:${PATH}"

# Ensure UV and West are in PATH
export PATH="/home/zephyr/.cargo/bin:/home/zephyr/.local/bin:${PATH}"

# Print welcome message
echo "🚀 Zephyr Development Environment"
echo "=================================="
echo "West version: $(west --version 2>/dev/null || echo 'Not found')"
echo "UV version: $(uv --version 2>/dev/null || echo 'Not found')"
echo "Zephyr SDK: ${ZEPHYR_SDK_INSTALL_DIR}"
echo "Working directory: $(pwd)"
echo ""

# Initialize workspace if needed (only for interactive usage)
if [ -t 1 ] && [ "$1" = "/bin/bash" ]; then
    echo "💡 Tip: Run 'init-workspace.sh' to initialize a new Zephyr workspace"
    echo "💡 Tip: Use 'west build -b <board> <app>' to build applications"
    echo ""
fi

# Execute the command
exec "$@"