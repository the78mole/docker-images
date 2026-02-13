# FreeRTOS POSIX Development Image

This Docker image provides a complete development environment for FreeRTOS applications using the POSIX/Linux simulator port. It's specifically designed for use as a **DevContainer** in VS Code and includes tools for developing and testing FreeRTOS-based middleware and system tasks.

## Features

### Build Tools
- **GCC/G++** - Standard C/C++ compilers
- **Make & CMake** - Build systems
- **Ninja** - Fast build tool
- **GDB** - GNU debugger for debugging FreeRTOS applications

### FreeRTOS Support
- **POSIX Port** - Run FreeRTOS tasks as native Linux binaries
- **Pre-configured Environment Variables**:
  - `FREERTOS_PATH=/workspace/FreeRTOS-Kernel`
  - `FREERTOS_TCP_PATH=/workspace/FreeRTOS-Plus-TCP`
  - `FREERTOS_PORT=GCC/Posix`

### Network Testing
- **Chrony NTP Server** - For testing NTP client implementations
- **Network Tools** - net-tools, iputils-ping, iproute2, curl, tcpdump
- **SSL/TLS Libraries** - libssl-dev, libmbedtls-dev

### Development Tools
- **Valgrind** - Memory leak detection
- **Strace** - System call tracing
- **Python3** - For build scripts and tools
- **Git** - Version control

## Usage

### As a DevContainer

Create a `.devcontainer/devcontainer.json` in your project:

```json
{
    "name": "FreeRTOS Development",
    "image": "ghcr.io/the78mole/freertos-dev-posix:latest",
    
    "runArgs": [
        "--cap-add=SYS_TIME",
        "--cap-add=NET_ADMIN",
        "--cap-add=NET_RAW"
    ],
    
    "remoteUser": "vscode",
    
    "postCreateCommand": "echo 'Welcome to FreeRTOS Development!' && cat /home/vscode/welcome.txt"
}
```

### As a Standalone Container

```bash
# Pull the image
docker pull ghcr.io/the78mole/freertos-dev-posix:latest

# Run interactively with network capabilities
docker run -it --rm \
    --cap-add=SYS_TIME \
    --cap-add=NET_ADMIN \
    -v $(pwd):/workspaces/project \
    ghcr.io/the78mole/freertos-dev-posix:latest
```

## NTP Server Setup

The image includes Chrony NTP server for testing NTP client implementations:

```bash
# Start the NTP server
start-chrony.sh

# Check server status
chronyc tracking
chronyc sources

# Test NTP query (requires ntpdate)
sudo apt-get install -y ntpdate
ntpdate -q localhost
```

## Building FreeRTOS Applications

### Using Make

```bash
# Clone FreeRTOS kernel if needed
git clone https://github.com/FreeRTOS/FreeRTOS-Kernel.git /workspace/FreeRTOS-Kernel

# Build your application
cd /workspaces/your-project
make
```

### Using CMake

```bash
mkdir -p build && cd build
cmake .. \
    -DFREERTOS_KERNEL_PATH=/workspace/FreeRTOS-Kernel \
    -DFREERTOS_PLUS_TCP_PATH=/workspace/FreeRTOS-Plus-TCP \
    -DFREERTOS_PORT=GCC/Posix
make
```

## Required Capabilities

For NTP functionality and time manipulation, the container needs these capabilities:

- `--cap-add=SYS_TIME` - Allows setting system time
- `--cap-add=NET_ADMIN` - Network administration (optional, for advanced networking)
- `--cap-add=NET_RAW` - Raw socket access (optional, for packet capture)

## Use Cases

This image is ideal for:

1. **Middleware Development** - Develop and test FreeRTOS middleware components on x86 before deploying to embedded hardware
2. **NTP Client Testing** - Test NTP synchronization tasks against a local NTP server
3. **System Task Development** - Develop system-level tasks (logging, networking, etc.) with full debugging capabilities
4. **Continuous Integration** - Run FreeRTOS application tests in CI/CD pipelines
5. **Education** - Learn FreeRTOS concepts without embedded hardware

## Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `FREERTOS_PATH` | `/workspace/FreeRTOS-Kernel` | Path to FreeRTOS kernel sources |
| `FREERTOS_TCP_PATH` | `/workspace/FreeRTOS-Plus-TCP` | Path to FreeRTOS-Plus-TCP sources |
| `FREERTOS_PORT` | `GCC/Posix` | FreeRTOS port to use |
| `TZ` | `UTC` | Timezone |
| `DEBIAN_FRONTEND` | `noninteractive` | Non-interactive apt-get |

## Installed Packages

- build-essential, gcc, g++, make, cmake, ninja-build, gdb, git
- libc6-dev, libssl-dev, libmbedtls-dev
- valgrind, strace
- chrony, net-tools, iputils-ping, iproute2, curl, tcpdump
- vim, nano, wget, tree, htop, sudo, ca-certificates
- python3, python3-pip

## Version

Current version: 1.0.0

## Base Image

Ubuntu 24.04 LTS

## License

This image configuration is provided as-is for use in the docker-images repository.

## Related Links

- [FreeRTOS Official Site](https://www.freertos.org/)
- [FreeRTOS POSIX Port Documentation](https://www.freertos.org/FreeRTOS-simulator-for-Linux.html)
- [FreeRTOS GitHub Repository](https://github.com/FreeRTOS/FreeRTOS-Kernel)
