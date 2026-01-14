# nRF Connect SDK Development Environment

A Docker image for Nordic nRF Connect SDK development with all necessary tools pre-installed.

## Features

- **Nordic nRF Connect SDK**: Complete development environment
- **nrfutil**: Nordic's command-line utility for nRF devices
- **West**: Zephyr's meta tool for managing repositories
- **Zephyr SDK**: Cross-compilation toolchain
- **DevContainer Support**: VS Code DevContainer configuration with recommended extensions
- **Development Tools**: GCC, CMake, Ninja, Python tools
- **Debugging**: GDB, OpenOCD support

## Quick Start

### Build the image
```bash
docker build -t nrfconnectsdk .
```

### Run interactive development session
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  --device /dev/ttyACM0:/dev/ttyACM0 \
  nrfconnectsdk
```

### Initialize nRF Connect SDK project
```bash
# Inside the container
west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.4.0 myapp
cd myapp
west update
```

### Build and flash example
```bash
west build -b nrf52840dk_nrf52840 samples/basic/blinky
west flash
```

## DevContainer Usage

Copy the included `.devcontainer/devcontainer.json` to your project root:

```bash
cp .devcontainer/devcontainer.json /path/to/your/project/.devcontainer/
```

**Included VS Code Extensions:**
- Nordic Semiconductor nRF Connect Extension Pack
- nRF Kconfig and DeviceTree support
- C/C++ Tools with nRF-specific paths
- CMake Tools
- Python support

## Available Commands

- `west` - Zephyr meta tool
- `nrfutil` - Nordic device utility
- `cmake` / `ninja` - Build tools
- `gdb` / `openocd` - Debugging
- `nrf-help` - Show common nRF commands

## Environment Variables

- `ZEPHYR_TOOLCHAIN_VARIANT=zephyr`
- `ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk`
- `PATH` includes nrfutil and local Python packages

## Device Access

When connecting nRF devices via USB:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  --privileged \
  -v /dev:/dev \
  nrfconnectsdk
```

## Version

Current version: 1.0.0

## License

This Docker image packages open-source tools. Individual tools maintain their respective licenses.