# Jumpstarter Development Environment

> **Complete Docker image for Jumpstarter development with Kind, Docker-in-Docker, and automated setup**

**📚 For complete documentation, examples, and all available Docker images, see the [main repository README](../../README.md#-jumpstarter-development-jumpstarter-dev)**

## Quick Start

```bash
# Complete setup (recommended)
docker run --privileged -p 30010:30010 -p 30011:30011 -it \
  ghcr.io/the78mole/jumpstarter-dev:latest \
  setup-jumpstarter.sh

# Interactive development
docker run --privileged -p 30010:30010 -p 30011:30011 -it \
  ghcr.io/the78mole/jumpstarter-dev:latest
```

## What's Included

- 🐳 **Docker-in-Docker** - Full container isolation with privileged mode
- ⚓ **Kind v0.20.0** - Kubernetes cluster with optimized config for Jumpstarter
- 🎯 **Automated Setup** - One-command deployment with `setup-jumpstarter.sh`
- 🔧 **Complete Toolchain** - kubectl, Helm, k9s, UV package manager
- 🐍 **Python 3.11** - With UV for modern dependency management
- 🤖 **Robot Framework** - Pre-installed for integration testing
- 🌐 **NodePort Access** - GRPC services on localhost:30010, localhost:30011

## Key Features

### Docker-in-Docker Implementation
- Based on official Microsoft DevContainer docker-in-docker feature
- Automatic daemon startup in privileged containers
- Robust retry logic and error handling
- cgroup v2 support and proper mount management

### Jumpstarter Integration
- Automatic Jumpstarter installation via Helm chart
- Pre-configured Kind cluster with proper NodePort mappings
- Ready-to-use development environment
- Direct access to GRPC Controller and Router services

### Development Tools
- **kubectl** - Kubernetes cluster management
- **Helm** - Package manager for Kubernetes applications
- **k9s** - Interactive Kubernetes dashboard
- **UV** - Modern Python package and project manager
- **Robot Framework** - Test automation framework

## Service Architecture

```
┌─────────────────────────────────────────┐
│ Docker Container (privileged)           │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Kind Cluster                        │ │
│ │                                     │ │
│ │ ┌─────────────┐ ┌─────────────────┐ │ │
│ │ │ Controller  │ │ Router          │ │ │
│ │ │ Pod         │ │ Pod             │ │ │
│ │ └─────────────┘ └─────────────────┘ │ │
│ │                                     │ │
│ │ NodePort Services:                  │ │
│ │ • Controller: 30010                 │ │
│ │ • Router: 30011                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Host Port Mapping:                      │
│ • localhost:30010 → Controller          │
│ • localhost:30011 → Router              │
│ • localhost:5080  → HTTP Ingress        │
└─────────────────────────────────────────┘
```

## Available Commands

**Setup & Management:**
```bash
setup-jumpstarter.sh          # Complete Jumpstarter deployment
kubectl get nodes              # Check cluster status  
kubectl get pods -n jumpstarter-lab  # Check Jumpstarter pods
k9s -n jumpstarter-lab        # Interactive dashboard
```

**Jumpstarter CLI:**
```bash
uv run jmp --help             # Jumpstarter CLI help
uv run jmp admin --help       # Admin commands
uv run jmp admin create exporter test-exporter --save
uv run jmp shell --client <client-name>
```

**Development:**
```bash
uv sync                       # Sync Python dependencies
uv run python                 # Python shell with Jumpstarter
```

## Troubleshooting

### Docker daemon not available
```bash
# Ensure container runs with privileged flag
docker run --privileged -it ghcr.io/the78mole/jumpstarter-dev:latest
```

### Ports not accessible
```bash
# Check port mappings
docker ps
kubectl get svc -n jumpstarter-lab

# Verify NodePort services
kubectl get svc -n jumpstarter-lab -o wide
```

### Jumpstarter pods not starting
```bash
# Check pod status and logs
kubectl get pods -n jumpstarter-lab
kubectl logs -n jumpstarter-lab -l app.kubernetes.io/name=jumpstarter-controller
kubectl logs -n jumpstarter-lab -l app.kubernetes.io/name=jumpstarter-router
kubectl describe pod -n jumpstarter-lab <pod-name>
```

### Kind cluster issues
```bash
# Recreate cluster
kind delete cluster
setup-jumpstarter.sh

# Check Kind cluster status
kind get clusters
kubectl cluster-info
```

## Development Workflow

1. **Start Development Container**
   ```bash
   docker run --privileged -p 30010:30010 -p 30011:30011 -it \
     ghcr.io/the78mole/jumpstarter-dev:latest
   ```

2. **Deploy Jumpstarter**
   ```bash
   setup-jumpstarter.sh
   # Wait for deployment to complete (~2-3 minutes)
   ```

3. **Verify Deployment**
   ```bash
   kubectl get pods -n jumpstarter-lab
   kubectl get svc -n jumpstarter-lab
   ```

4. **Create Test Exporter**
   ```bash
   uv run jmp admin create exporter test-exporter \
     --label environment=development \
     --save --insecure-tls-config
   ```

5. **Monitor with k9s**
   ```bash
   k9s -n jumpstarter-lab
   ```

6. **Access Services**
   - GRPC Controller: `localhost:30010`
   - GRPC Router: `localhost:30011`
   - HTTP Ingress: `localhost:5080`

## Docker Compose Integration

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
      - ./my-project:/workspace/project  # Mount your project
    environment:
      - WORKSPACE_DIR=/workspace
    command: setup-jumpstarter.sh
    healthcheck:
      test: ["CMD", "kubectl", "get", "pods", "-n", "jumpstarter-lab"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 120s

volumes:
  jumpstarter-data:
```

## VS Code DevContainer

Create `.devcontainer/devcontainer.json`:

```json
{
    "name": "Jumpstarter Development",
    "image": "ghcr.io/the78mole/jumpstarter-dev:latest",
    "privileged": true,
    "forwardPorts": [30010, 30011, 5080, 8082, 8083],
    "portsAttributes": {
        "30010": {"label": "GRPC Controller"},
        "30011": {"label": "GRPC Router"},
        "5080": {"label": "HTTP Ingress"}
    },
    "postCreateCommand": "setup-jumpstarter.sh",
    "remoteUser": "vscode",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-kubernetes-tools.vscode-kubernetes-tools",
                "ms-python.python",
                "redhat.vscode-yaml"
            ]
        }
    },
    "containerEnv": {
        "WORKSPACE_DIR": "/workspace"
    }
}
```

## CI/CD Integration

GitHub Actions example:

```yaml
name: Test Jumpstarter Integration
on: [push, pull_request]

jobs:
  test-jumpstarter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Jumpstarter Integration Tests
        run: |
          docker run --rm --privileged \
            -v ${{ github.workspace }}:/workspace/code \
            ghcr.io/the78mole/jumpstarter-dev:latest \
            bash -c "
              setup-jumpstarter.sh && 
              cd /workspace/code && 
              uv run robot tests/integration/
            "
      
      - name: Collect Test Results
        if: always()
        run: |
          docker run --rm --privileged \
            -v ${{ github.workspace }}:/workspace/code \
            ghcr.io/the78mole/jumpstarter-dev:latest \
            bash -c "
              kubectl logs -n jumpstarter-lab --all-containers=true > /workspace/code/jumpstarter-logs.txt
            "
```

## Technical Details

### Base Image
- **mcr.microsoft.com/devcontainers/base:ubuntu** - Official DevContainer base
- **Ubuntu 24.04 LTS** - Long-term support base system

### Tools & Versions
- **Docker CE 28.4.0** - Container runtime
- **Kind v0.20.0** - Kubernetes in Docker
- **kubectl v1.28.9** - Kubernetes client
- **Helm v3.15.4** - Kubernetes package manager
- **k9s (latest)** - Terminal UI for Kubernetes
- **UV 0.8.22** - Python package manager
- **Python 3.11** - Latest stable Python
- **Robot Framework 7.0** - Test automation

### Security & Isolation
- **Privileged mode required** for Docker-in-Docker functionality
- **Container isolation** via Docker's security features
- **Network isolation** via Docker networking
- **Volume isolation** for workspace data

### Performance Optimizations
- **Pre-built tools** - No compilation during container startup
- **Optimized Kind config** - Faster cluster initialization
- **Layer caching** - Efficient Docker builds
- **Resource limits** - Controlled memory and CPU usage

---

## 📚 More Information

- **Main Repository**: [docker-images README](../../README.md)
- **Jumpstarter Project**: [jumpstarter-dev on GitHub](https://github.com/jumpstarter-dev)
- **Issues & Support**: [GitHub Issues](https://github.com/the78mole/docker-images/issues)
- **Container Registry**: [ghcr.io/the78mole/jumpstarter-dev](https://ghcr.io/the78mole/jumpstarter-dev)

---

**Version**: 1.0.0  
**Maintainer**: the78mole  
**License**: Apache 2.0