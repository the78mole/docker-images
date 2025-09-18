# Zephyr Development Environment

This Docker image provides a complete Zephyr RTOS development environment with:

- **Ubuntu 24.04 LTS** base
- **UV** - Modern Python package and project manager
- **West** - Zephyr's meta-tool for managing repositories
- **Zephyr SDK 0.17.4** - Complete toolchain for all supported architectures
- **All dependencies** pre-installed for immediate development

## 🚀 Usage

### DevContainer (Recommended)

Create `.devcontainer/devcontainer.json`:

```json
{
    "name": "Zephyr Development",
    "image": "ghcr.io/the78mole/zephyr:1.4.0",
    "forwardPorts": [],
    "postCreateCommand": "init-workspace.sh",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.cpptools",
                "ms-python.python",
                "ms-vscode.cmake-tools",
                "twxs.cmake"
            ]
        }
    },
    "mounts": [
        "source=${localWorkspaceFolder},target=/workspaces,type=bind"
    ],
    "workspaceFolder": "/workspaces"
}
```

### GitHub Actions

```yaml
name: Zephyr Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/the78mole/zephyr:1.4.0
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Initialize Zephyr workspace
      run: |
        cd /workspaces
        west init -m https://github.com/zephyrproject-rtos/zephyr
        west update
    
    - name: Build sample application
      run: |
        cd /workspaces/zephyr
        west build -b qemu_x86 samples/hello_world
```

### Direct Docker Usage

```bash
# Run interactively
docker run -it --rm -v $(pwd):/workspaces ghcr.io/the78mole/zephyr:1.4.0

# Initialize workspace
init-workspace.sh

# Build an application
cd zephyr
west build -b qemu_x86 samples/hello_world
```

## 🛠️ Included Tools

- **West**: `west --version`
- **UV**: `uv --version` 
- **Zephyr SDK**: Located at `/home/zephyr/zephyr-sdk`
- **Python 3**: With all Zephyr dependencies
- **Build tools**: CMake, Ninja, GCC, etc.

## 🎯 Supported Boards

The Zephyr SDK includes toolchains for all officially supported boards:
- ARM Cortex-M (all variants)
- ARM Cortex-A
- RISC-V
- x86/x86_64
- ARC
- And many more...

## 📁 Directory Structure

- `/workspaces` - Your project workspace
- `/home/zephyr/zephyr-sdk` - Zephyr SDK installation (user-owned)
- `/home/zephyr` - Non-root user home directory

## 🔧 Environment Variables

- `ZEPHYR_TOOLCHAIN_VARIANT=zephyr`
- `ZEPHYR_SDK_INSTALL_DIR=/home/zephyr/zephyr-sdk`
- `ZEPHYR_BASE=/workspaces/zephyr` (after workspace init)

## 💡 Tips

1. **First time setup**: Run `init-workspace.sh` to initialize a Zephyr workspace
2. **Building**: Use `west build -b <board> <application_path>`
3. **Flashing**: Connect hardware and use `west flash`
4. **Testing**: Use `west build -b qemu_x86 -t run` for QEMU testing