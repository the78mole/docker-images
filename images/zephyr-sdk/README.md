# Zephyr SDK Development Environment

This Docker image provides a complete Zephyr development environment with a pre-installed Zephyr SDK.

## Features

- **Base**: Built on the `zephyr` base image with all development tools
- **Pre-installed Zephyr SDK**: Version 0.17.4 (automatically updated by renovate)
- **All toolchains**: ARM, RISC-V, x86, Xtensa, and more
- **UV Package Manager**: Modern Python package management
- **West Build Tool**: Zephyr's meta-tool for managing repositories
- **PyOCD Flash Tool**: For flashing and debugging
- **Ready to use**: No additional setup required

## Usage

### Run the container

```bash
# Interactive development
docker run --rm -it ghcr.io/the78mole/zephyr-sdk:latest

# Mount your project directory
docker run --rm -it -v $(pwd):/workspaces ghcr.io/the78mole/zephyr-sdk:latest
```

### Initialize a Zephyr workspace

```bash
# Initialize new workspace
~/init-workspace.sh

# Or manually
west init -m https://github.com/zephyrproject-rtos/zephyr
west update
```

### Build a sample

```bash
# Build hello_world for qemu_x86
west build -p auto -b qemu_x86 zephyr/samples/hello_world

# Run in emulator
west build -t run
```

## Pre-installed Tools

- **Zephyr SDK**: Complete cross-compilation toolchain
- **UV**: Fast Python package manager (`uv --version`)
- **West**: Zephyr build tool (`west --version`)
- **PyOCD**: Flash and debug tool (`pyocd --version`)
- **CMake & Ninja**: Build system tools
- **Git**: Version control

## Environment Variables

- `ZEPHYR_SDK_INSTALL_DIR`: `/home/zephyr/zephyr-sdk`
- `ZEPHYR_TOOLCHAIN_VARIANT`: `zephyr`
- `ZEPHYR_BASE`: `/workspaces/zephyr` (after workspace init)

## Supported Architectures

- ARM Cortex-M (arm-zephyr-eabi)
- ARM64 (aarch64-zephyr-elf)
- RISC-V (riscv64-zephyr-elf)
- x86 (x86_64-zephyr-elf)
- Xtensa (xtensa-espressif_esp32_zephyr-elf)
- And many more...

## Version Information

- Image Version: 1.0.0
- Zephyr SDK Version: 0.17.4
- Base Image: Ubuntu 24.04
- Python: 3.12

## Development Workflow

1. **Start container**: `docker run --rm -it -v $(pwd):/workspaces ghcr.io/the78mole/zephyr-sdk:latest`
2. **Initialize workspace**: `~/init-workspace.sh`
3. **Create application**: `west init -l .` in your app directory
4. **Build**: `west build -b <board> <source-dir>`
5. **Flash**: `west flash` (with connected hardware)

## Differences from Base Image

The `zephyr-sdk` image extends the base `zephyr` image with:

- Pre-installed Zephyr SDK (no runtime download required)
- All cross-compilation toolchains ready to use
- Optimized for CI/CD and production builds
- Larger image size but faster startup

For development without SDK or custom SDK versions, use the base `zephyr` image instead.
