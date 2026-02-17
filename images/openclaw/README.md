# OpenClaw AI Agent Environment

> **Complete Docker image for OpenClaw - an autonomous AI agent platform that helps with coding, research, and system automation**

**📚 For complete documentation, examples, and all available Docker images, see the [main repository README](../../README.md)**

## Quick Start

### Option 1: Docker Run (Direct)

```bash
# Run onboarding (first-time setup)
docker run -it --rm \
  -v ~/.openclaw:/home/ubuntu/.openclaw \
  ghcr.io/the78mole/openclaw:latest \
  pnpm run onboard

# Start the gateway
docker run -d --name openclaw \
  --restart unless-stopped \
  -p 18789:18789 \
  -v ~/.openclaw:/home/ubuntu/.openclaw \
  ghcr.io/the78mole/openclaw:latest
```

### Option 2: Docker Compose (Recommended for Portainer)

1. Create a `docker-compose.yml` file (or use the one in this directory)
2. Configure your AI provider API keys (see Environment Variables section)
3. Deploy with Docker Compose or import into Portainer

```bash
# Using Docker Compose
docker compose up -d

# View logs
docker compose logs -f

# Stop the service
docker compose down
```

## What's Included

- 🤖 **OpenClaw Gateway** - AI agent platform with autonomous capabilities
- 🌐 **Web Control UI** - Access at http://localhost:18789
- 🐍 **Node.js Runtime** - Complete Node.js 22.x LTS environment with pnpm
- 📦 **Pre-installed Dependencies** - All OpenClaw dependencies included
- 💾 **Persistent Data** - Configuration and workspace data preserved in volumes
- 🔐 **Secure Setup** - User-based execution, no root access needed

## Installation Guide for Portainer

### Prerequisites

- Portainer installed and running
- Access to Portainer web UI
- API keys for your preferred AI provider (Anthropic, OpenAI, etc.)

### Step-by-Step Installation

1. **Access Portainer**
   - Open Portainer web interface (usually http://localhost:9000)
   - Navigate to your environment (local or remote)

2. **Create Stack**
   - Click on "Stacks" in the left sidebar
   - Click "+ Add stack" button
   - Name your stack: `openclaw`

3. **Configure the Stack**
   - Choose "Web editor" option
   - Copy the contents of `docker-compose.yml` into the editor
   - OR use "Upload from computer" to upload the docker-compose.yml file

4. **Set Environment Variables**
   - Scroll down to "Environment variables" section
   - Add your API keys:
     - Name: `ANTHROPIC_API_KEY`, Value: `your-api-key-here`
     - OR Name: `OPENAI_API_KEY`, Value: `your-api-key-here`
   - You can also edit the docker-compose.yml directly to add these

5. **Deploy the Stack**
   - Click "Deploy the stack"
   - Wait for the container to pull and start (first time may take a few minutes)

6. **Run Onboarding (First Time Only)**
   - Go to "Containers" in Portainer
   - Find the `openclaw-gateway` container
   - Click on the container name
   - Click "Console" → "Connect"
   - Run: `pnpm run onboard`
   - Follow the onboarding wizard to configure your AI provider

7. **Access OpenClaw**
   - Open http://localhost:18789 in your browser
   - You should see the OpenClaw Control UI
   - Paste your gateway token (from onboarding) into Settings

### Updating Configuration

To change settings after deployment:
1. Go to Stacks → openclaw
2. Click "Editor"
3. Modify the docker-compose.yml
4. Click "Update the stack"
5. Select "Re-pull image and redeploy" if you want the latest version

## Environment Variables

Configure these in your docker-compose.yml or Portainer environment variables:

### AI Provider API Keys (Choose one or multiple)

- `ANTHROPIC_API_KEY` - For Claude AI models (recommended)
- `OPENAI_API_KEY` - For GPT models
- `GOOGLE_API_KEY` - For Gemini models
- `AZURE_OPENAI_API_KEY` - For Azure OpenAI

### OpenClaw Configuration

- `OPENCLAW_HOME` - Home directory for OpenClaw data (default: `/home/ubuntu/.openclaw`)

## Key Features

### Autonomous AI Agent
- Executes complex tasks autonomously
- Interacts with your system safely through sandboxed environments
- Learns from interactions and improves over time

### Multi-Provider Support
- Works with multiple AI providers
- Easy switching between different models
- Cost-effective operation with provider comparison

### Secure Execution
- Non-root user execution
- Isolated workspace environment
- Controlled system access through defined APIs

### Web-Based Control
- Intuitive web interface on port 18789
- Real-time task monitoring
- Easy configuration and management

## Available Commands

**Inside the container:**
```bash
# Run onboarding wizard
pnpm run onboard

# Start gateway in foreground
pnpm run gateway start -- --foreground

# Start gateway as daemon
pnpm run gateway start

# Stop gateway
pnpm run gateway stop

# Check gateway status
pnpm run gateway status

# Access dashboard
pnpm run dashboard

# Device management
pnpm run devices list
pnpm run devices approve <requestId>
```

## Volumes

The image uses two persistent volumes:

- `openclaw-data` - Stores OpenClaw configuration, credentials, and cache
- `openclaw-workspace` - Stores project files and workspace data

**Important:** Do not delete these volumes unless you want to reset OpenClaw completely.

## Ports

- `18789` - OpenClaw Control UI and API

## Usage Examples

### Basic Usage

```bash
# Start OpenClaw
docker compose up -d

# View logs
docker compose logs -f openclaw

# Execute a command inside the container
docker compose exec openclaw pnpm run gateway status
```

### With Environment Variables

```bash
# Set API key via environment file
echo "ANTHROPIC_API_KEY=your-key-here" > .env
docker compose up -d
```

### Development Mode

```bash
# Run with interactive console
docker run -it --rm \
  -p 18789:18789 \
  -v ~/.openclaw:/home/ubuntu/.openclaw \
  ghcr.io/the78mole/openclaw:latest \
  bash
```

## Troubleshooting

### OpenClaw not starting

```bash
# Check logs
docker compose logs openclaw

# Verify API keys are set
docker compose exec openclaw env | grep API_KEY

# Check if port is already in use
netstat -tulpn | grep 18789
```

### Cannot access UI at localhost:18789

```bash
# Verify container is running
docker compose ps

# Check port mapping
docker compose port openclaw 18789

# Test connectivity
curl http://localhost:18789
```

### Gateway token issues

```bash
# Regenerate token by running onboarding again
docker compose exec openclaw pnpm run onboard

# Check token file
docker compose exec openclaw cat /home/ubuntu/.openclaw/.env
```

### Permission errors

```bash
# Fix volume permissions
docker compose down
docker volume rm openclaw-data openclaw-workspace
docker compose up -d
docker compose exec openclaw pnpm run onboard
```

## Advanced Configuration

### Custom Workspace Location

Mount your own workspace directory:

```yaml
volumes:
  - ./my-projects:/home/ubuntu/.openclaw/workspace
```

### Multiple AI Providers

Configure multiple providers for redundancy:

```yaml
environment:
  - ANTHROPIC_API_KEY=your-anthropic-key
  - OPENAI_API_KEY=your-openai-key
  - GOOGLE_API_KEY=your-google-key
```

### Resource Limits

Add resource constraints:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
    reservations:
      cpus: '1'
      memory: 2G
```

## Security Considerations

1. **API Keys**: Never commit API keys to version control. Use environment variables or secrets.
2. **Network Access**: By default, OpenClaw is only accessible on localhost. To expose externally, use a reverse proxy with authentication.
3. **Volume Permissions**: The container runs as user `ubuntu` (UID 1000). Ensure mounted volumes have appropriate permissions.
4. **Updates**: Regularly pull the latest image to get security updates.

## VS Code DevContainer

Create `.devcontainer/devcontainer.json`:

```json
{
    "name": "OpenClaw Development",
    "image": "ghcr.io/the78mole/openclaw:latest",
    "forwardPorts": [18789],
    "portsAttributes": {
        "18789": {"label": "OpenClaw UI"}
    },
    "postCreateCommand": "pnpm run onboard",
    "remoteUser": "ubuntu",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-python.python",
                "dbaeumer.vscode-eslint"
            ]
        }
    }
}
```

## Integration Examples

### GitHub Actions

```yaml
name: OpenClaw Task
on: [push]

jobs:
  run-openclaw:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run OpenClaw Analysis
        run: |
          docker run --rm \
            -v ${{ github.workspace }}:/workspace \
            -e ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }} \
            ghcr.io/the78mole/openclaw:latest \
            pnpm run analyze /workspace
```

### Automated Backups

```bash
#!/bin/bash
# Backup OpenClaw data
docker compose exec openclaw tar czf /tmp/openclaw-backup.tar.gz /home/ubuntu/.openclaw
docker cp openclaw-gateway:/tmp/openclaw-backup.tar.gz ./openclaw-backup-$(date +%Y%m%d).tar.gz
```

## Performance Tips

1. **First Run**: Initial npm install in the container takes time. Subsequent starts are faster.
2. **Volume Performance**: Use named volumes (default) for better performance than bind mounts.
3. **Resource Allocation**: Allocate at least 2GB RAM for optimal performance.
4. **Caching**: OpenClaw caches model responses. Keep the data volume to benefit from caching.

## Documentation & Resources

- **Official OpenClaw Docs**: https://docs.openclaw.ai
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **Docker Installation Guide**: https://docs.openclaw.ai/install/docker
- **Main Repository**: [docker-images README](../../README.md)
- **Issues & Support**: [GitHub Issues](https://github.com/the78mole/docker-images/issues)

## Technical Details

### Base Image
- **Ubuntu 24.04 LTS** - Long-term support base system

### Tools & Versions
- **Node.js 22.x LTS** - JavaScript runtime from NodeSource
- **pnpm 10.23.0** - Fast, disk space efficient package manager
- **OpenClaw** - Latest from main branch

### Networking
- **Port 18789** - HTTP API and Control UI
- **Default bind**: 0.0.0.0 (all interfaces)

---

**Version**: 1.0.0  
**Maintainer**: the78mole  
**License**: MIT

---

## Quick Reference

| Item | Value |
|------|-------|
| **Image** | `ghcr.io/the78mole/openclaw:latest` |
| **Web UI** | http://localhost:18789 |
| **Data Volume** | `openclaw-data` |
| **Workspace Volume** | `openclaw-workspace` |
| **Default User** | `ubuntu` (UID 1000) |
| **Working Directory** | `/opt/openclaw` |
