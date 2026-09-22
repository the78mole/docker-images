# 🐳 Docker Images Collection

> **Unified repository for all Docker development images with matrix-based CI/CD workflows**

This repository consolidates multiple Docker images into a single, maintainable collection with intelligent CI/CD workflows that build only changed images.

[![Build Status](https://github.com/the78mole/docker-images/actions/workflows/docker-build.yml/badge.svg)](https://github.com/the78mole/docker-images/actions/workflows/docker-build.yml)
[![License: MIT](https://img.shields.io/github/license/the78mole/docker-images)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/the78mole/docker-images)](https://github.com/the78mole/docker-images/releases)

---

## 📦 Available Images

All images are available on GitHub Container Registry at `ghcr.io/the78mole/<image-name>:latest`

| Image | Purpose | Size | Usage |
|-------|---------|------|-------|
| **`kicaddev`** | KiCad CLI tools & production automation | ~9.6GB | PCB design, Gerber export, documentation |
| **`platformio`** | PlatformIO development environment | ~729MB | Microcontroller firmware development |
| **`zephyr`** | Zephyr RTOS development environment | ~21.5GB | RTOS firmware development, embedded systems |
| **`wordpress-smtp`** | WordPress with SMTP support | ~740MB | WordPress deployment with email |
| **`heishamon-dev`** | HeishaMon development (Arduino CLI) | ~5.44GB | Arduino-based IoT development |
| **`heishamon-dev-pio`** | HeishaMon development (PlatformIO) | ~1.7GB | PlatformIO-based IoT development |
| **`arduino-cli`** | Arduino CLI development | ~587MB | Arduino project compilation |
| **`latex`** | LaTeX/TeXLive environment | ~4.8GB | Document generation, academic papers |
| **`latex-node`** | LaTeX + Node.js development | ~7.99GB | Document generation with JavaScript tooling |
| **`nrfconnectsdk`** | Nordic nRF Connect SDK development | ~761MB | nRF microcontroller firmware, Zephyr RTOS |

---

## 🚀 Quick Start

### Pull and Run Images

```bash
# KiCad development - export production files
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/kicaddev:latest \
  kicad_export project.kicad_pro

# PlatformIO development
docker run --rm -it -v $(pwd):/workspace \
  ghcr.io/the78mole/platformio:latest \
  pio run

# Zephyr RTOS development
docker run --rm -it -v $(pwd):/workspaces \
  ghcr.io/the78mole/zephyr:latest \
  west build -b qemu_x86 samples/hello_world

# WordPress with SMTP
docker run -d \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_USER=your@email.com \
  -e SMTP_PASS=yourpassword \
  ghcr.io/the78mole/wordpress-smtp:latest

# Arduino CLI compilation
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/arduino-cli:latest \
  arduino-cli compile --fqbn esp32:esp32:esp32 .

# LaTeX document compilation
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/latex:latest \
  pdflatex document.tex

# LaTeX + Node.js development
docker run --rm -it -v $(pwd):/workspace \
  ghcr.io/the78mole/latex-node:latest

# nRF Connect SDK development
docker run --rm -it -v $(pwd):/workspace \
  --device /dev/ttyACM0:/dev/ttyACM0 \
  ghcr.io/the78mole/nrfconnectsdk:latest
```

### Development Containers (VS Code)

Each image can be used as a development container. Example `.devcontainer/devcontainer.json`:

```json
{
    "name": "KiCad Development",
    "image": "ghcr.io/the78mole/kicaddev:latest",
    "workspaceFolder": "/workspace",
    "remoteUser": "kicad",
    "forwardPorts": [8000],
    "postCreateCommand": "echo 'Ready! Use kicad-help for available commands.'"
}
```

---

## 🏗️ Repository Structure

```
docker-images/
├── .github/workflows/          # CI/CD workflows
│   ├── docker-build.yml        # Matrix-based build workflow
│   └── cleanup-pr-images.yml   # Removes PR image tags from GHCR
├── images/                     # Docker image sources
│   ├── kicaddev/              # KiCad CLI tools
│   │   ├── Dockerfile
│   │   ├── VERSION            # Independent image versioning
│   │   ├── requirements.txt
│   │   └── scripts/           # KiCad automation scripts
│   ├── platformio/            # PlatformIO development
│   ├── zephyr/                # Zephyr RTOS development
│   ├── wordpress-smtp/        # WordPress + SMTP
│   ├── heishamon-dev/         # HeishaMon development
│   │   ├── Dockerfile         # Arduino CLI version
│   │   └── Dockerfile.pio     # PlatformIO version
│   ├── arduino-cli/           # Arduino CLI
│   └── latex/                 # LaTeX environment
├── renovate.json              # Dependency management
├── .pre-commit-config.yaml    # Code quality hooks
└── README.md                  # This file
```

---

## 🔄 CI/CD Strategy

### Matrix-Based Builds

Our workflow intelligently builds only changed images:

1. **Change Detection** - Detects which image directories have changes
2. **Version Validation** - Ensures VERSION files are updated when content changes
3. **Matrix Building** - Builds only affected images in parallel
4. **Smart Caching** - Uses GitHub Actions cache for faster builds
5. **Multi-tagging** - Tags with `latest`, version, and repository release

### Workflow Triggers

- **Push to `main`** - Builds changed images and creates releases
- **Pull Requests** - Builds all images for validation
- **Manual Dispatch** - Builds all images on demand

### PR Image Cleanup

PR builds push `<image>:<VERSION>-pr<n>` and `<image>:latest-pr<n>` so dependent
images can be built and tested against them. `cleanup-pr-images.yml` removes
those tags from GHCR again, so the registry does not keep the leftovers of every
merged PR:

- **Automatic** - runs when a pull request is closed and deletes its PR tags
- **Manual sweep** - `workflow_dispatch` without a PR number cleans up every
  closed PR still present in the registry. It defaults to a dry run that only
  lists what it would delete
- **Safety** - a package version is deleted only if it carries nothing but PR
  tags of PRs that are no longer open. Release tags (`latest`, `1.2.3`) and
  untagged versions are never touched

### Version Management

- **Repository Versioning** - Uses `paulhatch/semantic-version` for repository releases
- **Image Versioning** - Independent versions in each `images/*/VERSION` file
- **Change Validation** - Fails if image content changes without version update

---

## 📋 Image Documentation

### 🔧 KiCad Development (`kicaddev`)

Complete KiCad CLI environment for PCB production automation.

**Features:**
- KiCad 9.0 CLI tools
- Python automation libraries (KiKit, PCBDraw)
- Sphinx documentation tools
- LaTeX support for PDF generation
- Interactive HTML BOM generator

**Usage:**
```bash
# Export production files
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/kicaddev:latest \
  kicad_export project.kicad_pro

# Generate documentation
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/kicaddev:latest \
  kicad_docs_build

# Interactive development
docker run --rm -it -v $(pwd):/workspace \
  ghcr.io/the78mole/kicaddev:latest bash
```

### ⚡ PlatformIO Development (`platformio`)

Minimal PlatformIO environment for microcontroller development.

**Features:**
- PlatformIO Core
- Pre-commit hooks
- ESPTool for ESP32/ESP8266
- USB device support

**Usage:**
```bash
# Initialize project
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/platformio:latest \
  pio project init --board esp32dev

# Build firmware
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/platformio:latest \
  pio run
```

### 🚀 Zephyr RTOS Development (`zephyr`)

Complete Zephyr RTOS development environment for embedded systems.

**Features:**
- Ubuntu 24.04 LTS base
- UV - Modern Python package and project manager  
- West - Zephyr's meta-tool for managing repositories
- Zephyr SDK 0.17.4 - Complete toolchain for all supported architectures
- Pre-installed dependencies for immediate development

**Usage:**
```bash
# Interactive development
docker run --rm -it -v $(pwd):/workspaces \
  ghcr.io/the78mole/zephyr:latest

# Initialize workspace
docker run --rm -v $(pwd):/workspaces \
  ghcr.io/the78mole/zephyr:latest \
  init-workspace.sh

# Build sample application
docker run --rm -v $(pwd):/workspaces \
  ghcr.io/the78mole/zephyr:latest \
  west build -b qemu_x86 samples/hello_world
```

### 📧 WordPress SMTP (`wordpress-smtp`)

WordPress with built-in SMTP support for reliable email delivery.

**Environment Variables:**
- `SMTP_HOST` - SMTP server hostname
- `SMTP_PORT` - SMTP port (default: 587)
- `SMTP_USER` - SMTP username
- `SMTP_PASS` - SMTP password
- `SMTP_FROM` - From email address

**Usage:**
```bash
docker run -d \
  -p 80:80 \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_USER=your@email.com \
  -e SMTP_PASS=yourpassword \
  -e SMTP_FROM=wordpress@yourdomain.com \
  ghcr.io/the78mole/wordpress-smtp:latest
```

### 🔌 HeishaMon Development (`heishamon-dev` / `heishamon-dev-pio`)

Development environments for HeishaMon IoT project.

**Two variants:**
- `heishamon-dev` - Arduino CLI based
- `heishamon-dev-pio` - PlatformIO based (recommended)

**Pre-installed libraries:**
- ESP32/ESP8266 cores
- ArduinoJSON, PubSubClient
- OneWire, DallasTemperature
- Adafruit NeoPixel

### 🔨 Arduino CLI (`arduino-cli`)

Lightweight Arduino CLI environment.

**Usage:**
```bash
# Install ESP32 core
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/arduino-cli:latest \
  arduino-cli core install esp32:esp32

# Compile sketch
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/arduino-cli:latest \
  arduino-cli compile --fqbn esp32:esp32:esp32 .
```

### 📄 LaTeX Environment (`latex`)

Complete TeXLive installation for document generation.

**Features:**
- Full TeXLive scheme
- FontConfig support
- Common packages pre-installed
- PDF/XeLaTeX/LuaLaTeX support

**Usage:**
```bash
# Compile LaTeX document
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/latex:latest \
  pdflatex document.tex

# Using latexmk
docker run --rm -v $(pwd):/workspace \
  ghcr.io/the78mole/latex:latest \
  latexmk -pdf document.tex
```

### 📄📜 LaTeX + Node.js Environment (`latex-node`)

Combined LaTeX and Node.js environment for modern documentation workflows with JavaScript tooling.

**Features:**
- Complete TeXLive distribution
- Node.js LTS with npm
- Document generation tools (Mermaid, markdown-pdf, reveal-md)
- TypeScript support
- Browser automation (Playwright)

**Usage:**
```bash
# LaTeX + Node.js development
docker run --rm -it -v $(pwd):/workspace \
  ghcr.io/the78mole/latex-node:latest

# Inside container:
# pdflatex document.tex && npm run build
# mmdc -i diagram.mmd -o diagram.png
# reveal-md slides.md --theme sky
```

### 📱 Nordic nRF Connect SDK (`nrfconnectsdk`)

Complete development environment for Nordic nRF microcontrollers using the nRF Connect SDK.

**Features:**
- nRF Connect SDK with Zephyr RTOS
- nrfutil command-line tools
- Pre-installed VS Code extensions for nRF development
- Zephyr SDK v0.16.1
- West meta tool for project management
- GDB and OpenOCD for debugging

**Usage:**
```bash
# Initialize nRF project
docker run --rm -it -v $(pwd):/workspace \
  --device /dev/ttyACM0:/dev/ttyACM0 \
  ghcr.io/the78mole/nrfconnectsdk:latest

# Inside container:
# west init -m https://github.com/nrfconnect/sdk-nrf --mr v2.4.0 myapp
# west update
# west build -b nrf52840dk_nrf52840 samples/basic/blinky
```

---

## 🛠️ Development

### Building Images Locally

```bash
# Build specific image
docker build -t my-kicaddev images/kicaddev/

# Build with specific tag
docker build -t ghcr.io/the78mole/kicaddev:dev images/kicaddev/
```

### Testing Changes

```bash
# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Run pre-commit on all files
pre-commit run --all-files

# Test specific image
docker run --rm -it my-kicaddev bash
```

### Contributing

1. **Fork the repository**
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Update VERSION file** when changing image content
4. **Test changes** locally
5. **Commit changes** (`git commit -m 'Add amazing feature'`)
6. **Push branch** (`git push origin feature/amazing-feature`)
7. **Open Pull Request**

**Important:** Always update the `images/*/VERSION` file when making changes to image content. The CI will fail if image files change without version updates.

---

## 🔧 Configuration

### Renovate Bot

Automatic dependency updates are managed by Renovate:

- **Schedule** - Weekly updates on Monday mornings
- **Docker Images** - Automatic base image updates
- **Python Dependencies** - Automatic pip requirements updates
- **GitHub Actions** - Automatic action version updates

### Pre-commit Hooks

Code quality is enforced by pre-commit hooks:

- **YAML/JSON validation**
- **Markdown linting**
- **Shell script linting** (shellcheck)
- **Dockerfile linting** (hadolint)
- **Trailing whitespace removal**

---

## 📊 Workflow Features

### Change Detection

The workflow automatically detects which images need rebuilding:

```yaml
# Example: Only kicaddev changed
changed_images: ["kicaddev"]

# Matrix builds only affected image
strategy:
  matrix:
    include:
      - image: kicaddev  # ✅ Built
      - image: platformio # ⏭️ Skipped
```

### Version Validation

Prevents builds with stale versions:

```bash
# If image content changes but VERSION file doesn't:
❌ Image content changed but VERSION file was not updated!
Please update images/kicaddev/VERSION file when making changes.
```

### Smart Tagging

Each image gets multiple tags:

- `latest` - Always points to newest build
- `{image-version}` - From VERSION file (e.g., `1.2.0`)
- `{repo-version}` - Repository release tag (e.g., `v2.1.0`)

---

## 📈 Monitoring

### Build Status

- [![Build Status](https://github.com/the78mole/docker-images/actions/workflows/docker-build.yml/badge.svg)](https://github.com/the78mole/docker-images/actions/workflows/docker-build.yml)
- [GitHub Actions](https://github.com/the78mole/docker-images/actions)
- [Container Registry](https://github.com/the78mole/docker-images/pkgs/container)

### Image Sizes

Monitor image sizes to prevent bloat:

```bash
# Check image sizes
docker images ghcr.io/the78mole/*

# Clean up old images
docker system prune -f
```

---

## 🤝 Support

- **Issues** - [GitHub Issues](https://github.com/the78mole/docker-images/issues)
- **Discussions** - [GitHub Discussions](https://github.com/the78mole/docker-images/discussions)
- **Documentation** - This README and individual image docs

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [KiCad EDA](https://www.kicad.org/) - Open source electronics design
- [PlatformIO](https://platformio.org/) - Professional embedded development
- [WordPress](https://wordpress.org/) - Web publishing platform
- [Arduino](https://www.arduino.cc/) - Open source electronics prototyping
- [LaTeX](https://www.latex-project.org/) - Document preparation system
- All the open source maintainers whose work makes this possible

---

**Built with ❤️ for the hardware and software development community**
