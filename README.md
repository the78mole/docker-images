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
| **`jumpstarter-dev`** | Complete Jumpstarter development environment | ~1.58GB | Kind cluster, Docker-in-Docker, Robot Framework |
| **`openclaw`** | OpenClaw AI agent platform | ~TBD | AI-powered autonomous agent, coding assistant |

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

# Jumpstarter development - complete setup
docker run --privileged -p 30010:30010 -p 30011:30011 -it \
  ghcr.io/the78mole/jumpstarter-dev:latest \
  setup-jumpstarter.sh

# OpenClaw AI agent - autonomous coding assistant
docker run -d --name openclaw -p 18789:18789 \
  -v ~/.openclaw:/home/node/.openclaw \
  -e ANTHROPIC_API_KEY=your-api-key \
  ghcr.io/the78mole/openclaw:latest
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
│   └── docker-build.yml        # Matrix-based build workflow
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

### �🚀 Jumpstarter Development Environment (`jumpstarter-dev`)

Complete Jumpstarter development environment with Docker-in-Docker, Kubernetes, and all necessary tools pre-installed.

**Features:**
- Docker-in-Docker for isolated development
- Kind (Kubernetes in Docker) v0.20.0 with optimized configuration
- Automatic Jumpstarter installation via Helm
- Pre-installed tools: kubectl, Helm, k9s, UV package manager
- Python 3.11 with Robot Framework for testing
- Direct localhost access to all services via NodePorts

**Architecture:**
- **Kind Cluster** - Local Kubernetes cluster for development
- **NodePorts** - GRPC services exposed on localhost:30010, localhost:30011
- **Docker-in-Docker** - Proper container isolation with privileged mode
- **UV Package Manager** - Modern Python dependency management
- **Automatic Setup** - One-command deployment of complete stack

**Usage:**
```bash
# Complete Jumpstarter setup (recommended)
docker run --privileged -p 30010:30010 -p 30011:30011 -it \
  ghcr.io/the78mole/jumpstarter-dev:latest \
  setup-jumpstarter.sh

# Interactive development
docker run --privileged -p 30010:30010 -p 30011:30011 -it \
  ghcr.io/the78mole/jumpstarter-dev:latest

# With workspace mount
docker run --privileged -p 30010:30010 -p 30011:30011 \
  -v $(pwd):/workspace/project -it \
  ghcr.io/the78mole/jumpstarter-dev:latest

# Check services after setup
docker run --privileged -it ghcr.io/the78mole/jumpstarter-dev:latest \
  bash -c "setup-jumpstarter.sh && kubectl get pods -n jumpstarter-lab && k9s -n jumpstarter-lab"
```

**Available Commands:**
- `setup-jumpstarter.sh` - Complete Jumpstarter setup with Kind + Helm
- `kubectl get nodes` - Check cluster status
- `k9s` - Interactive Kubernetes dashboard
- `uv run jmp --help` - Jumpstarter CLI commands
- `uv run jmp admin create exporter <name>` - Create new exporter

**Service Access:**
- **GRPC Controller**: localhost:30010 (NodePort)
- **GRPC Router**: localhost:30011 (NodePort)
- **HTTP Ingress**: localhost:5080
- **Kubernetes Dashboard**: Run `k9s` in container

**Docker Compose Example:**
```yaml
version: '3.8'
services:
  jumpstarter-dev:
    image: ghcr.io/the78mole/jumpstarter-dev:latest
    privileged: true
    ports:
      - "30010:30010"  # GRPC Controller
      - "30011:30011"  # GRPC Router
      - "5080:5080"    # HTTP Ingress
    volumes:
      - jumpstarter-data:/workspace
    command: setup-jumpstarter.sh
volumes:
  jumpstarter-data:
```

**Development Workflow:**
1. Start container: `docker run --privileged -p 30010:30010 -p 30011:30011 -it ghcr.io/the78mole/jumpstarter-dev:latest`
2. Run setup: `setup-jumpstarter.sh`
3. Verify services: `kubectl get pods -n jumpstarter-lab`
4. Create exporter: `uv run jmp admin create exporter test-exporter --save --insecure-tls-config`
5. Access dashboard: `k9s -n jumpstarter-lab`

**DevContainer Support:**
This image is fully compatible with VS Code DevContainers. Create `.devcontainer/devcontainer.json`:
```json
{
    "name": "Jumpstarter Development",
    "image": "ghcr.io/the78mole/jumpstarter-dev:latest",
    "privileged": true,
    "forwardPorts": [30010, 30011, 5080],
    "postCreateCommand": "setup-jumpstarter.sh",
    "remoteUser": "vscode"
}
```

### 🤖 OpenClaw AI Agent Platform (`openclaw`)

Complete OpenClaw AI agent environment for autonomous task execution and coding assistance.

**Features:**
- OpenClaw AI agent platform with web UI
- Node.js 20.x LTS runtime
- Autonomous task execution
- Multi-provider AI support (Anthropic, OpenAI, Google)
- Persistent configuration and workspace
- Web-based control interface

**Usage:**
```bash
# First-time onboarding
docker run -it --rm \
  -v ~/.openclaw:/home/node/.openclaw \
  ghcr.io/the78mole/openclaw:latest \
  npm run onboard

# Start gateway
docker run -d --name openclaw \
  --restart unless-stopped \
  -p 18789:18789 \
  -v ~/.openclaw:/home/node/.openclaw \
  -e ANTHROPIC_API_KEY=your-api-key \
  ghcr.io/the78mole/openclaw:latest

# Access web UI at http://localhost:18789

# Using Docker Compose (recommended)
cd images/openclaw
docker compose up -d
```

**Docker Compose Example:**
```yaml
version: '3.8'
services:
  openclaw:
    image: ghcr.io/the78mole/openclaw:latest
    container_name: openclaw-gateway
    restart: unless-stopped
    ports:
      - "18789:18789"
    volumes:
      - openclaw-data:/home/node/.openclaw
      - openclaw-workspace:/home/node/.openclaw/workspace
    environment:
      - ANTHROPIC_API_KEY=your-api-key-here
      - OPENCLAW_HOME=/home/node/.openclaw

volumes:
  openclaw-data:
  openclaw-workspace:
```

**Portainer Setup:**
1. Create new stack in Portainer
2. Use the docker-compose.yml from `images/openclaw/`
3. Add your AI provider API keys in environment variables
4. Deploy the stack
5. Run onboarding via console: `npm run onboard`
6. Access UI at http://localhost:18789

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
