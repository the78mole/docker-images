# Jumpstarter Development Environment

Ein vollständiges Docker Image für die Jumpstarter-Entwicklung mit allen notwendigen Tools und automatischer Setup-Funktionalität.

## Features

- 🐳 **Docker-in-Docker** für isolierte Entwicklung
- ⚓ **Kubernetes (Kind)** Cluster mit offizieller Jumpstarter-Konfiguration  
- 🎯 **Automatische Installation** von Jumpstarter via Helm
- 🔧 **Alle Tools vorinstalliert**: kubectl, Helm, Kind, k9s, UV
- 🐍 **Python 3.11** mit UV Package Manager
- 🤖 **Robot Framework** für Integration Tests
- 🌐 **Direkter localhost-Zugang** zu allen Services

## Quick Start

### Docker Run
```bash
# Einfacher Start
docker run --rm -it --privileged -p 30010:30010 -p 30011:30011 the78mole/jumpstarter-dev

# Mit automatischem Setup
docker run --rm -it --privileged -p 30010:30010 -p 30011:30011 the78mole/jumpstarter-dev setup-jumpstarter.sh
```

### Docker Compose
```yaml
version: '3.8'
services:
  jumpstarter-dev:
    image: the78mole/jumpstarter-dev:latest
    privileged: true
    ports:
      - "30010:30010"  # GRPC Controller
      - "30011:30011"  # GRPC Router
      - "5080:5080"    # HTTP Ingress
      - "8082:8082"    # Additional GRPC
      - "8083:8083"    # Additional GRPC
    volumes:
      - jumpstarter-data:/workspace
    command: setup-jumpstarter.sh

volumes:
  jumpstarter-data:
```

## Vorinstallierte Tools

Das Image enthält alle notwendigen Tools:

- ✅ **Docker** (Docker-in-Docker)
- ✅ **kubectl** (Neueste stabile Version)
- ✅ **Helm** (Neueste Version)
- ✅ **Kind** (v0.20.0) 
- ✅ **k9s** (Kubernetes Dashboard)
- ✅ **UV** (Python Package Manager)
- ✅ **Python 3.11** mit Jumpstarter Dependencies
- ✅ **Robot Framework** für Integration Tests
- ✅ **Network Tools** (netcat, telnet, ping)
- ✅ **JSON Tools** (jq)

## Service-Zugriff

Nach dem Setup sind Services über NodePorts erreichbar:

- 🔗 **GRPC Controller**: localhost:30010 (NodePort)
- 🔗 **GRPC Router**: localhost:30011 (NodePort)  
- 🌐 **HTTP Ingress**: localhost:5080
- 📊 **k9s Dashboard**: `k9s` im Terminal ausführen

## Verfügbare Befehle

```bash
# Entwicklungsumgebung
setup-jumpstarter.sh     # Komplettes Setup (empfohlen)
kubectl get nodes        # Cluster-Status prüfen  
k9s                      # Kubernetes Dashboard
k9s -n jumpstarter-lab   # Jumpstarter Namespace

# Python/Jumpstarter CLI
uv --help               # Python Package Manager
uv run jmp --help       # Jumpstarter CLI
uv run jmp admin --help # Admin Befehle

# Service Management
kubectl get pods -n jumpstarter-lab        # Pod Status
kubectl logs -n jumpstarter-lab <pod>      # Pod Logs
kubectl get svc -n jumpstarter-lab         # Services
```

## Python-Entwicklung

Das Projekt nutzt **UV** für modernes Python Dependency Management:

```bash
# Python Umgebung (automatisch mit setup-jumpstarter.sh)
uv sync

# Jumpstarter CLI verwenden
uv run jmp admin create exporter my-exporter
uv run jmp admin get --help
uv run jmp shell --client <client-name>

# Python Shell mit Jumpstarter
uv run python
```

## Beispiel-Workflow

```bash
# 1. Container starten
docker run --rm -it --privileged -p 30010:30010 -p 30011:30011 the78mole/jumpstarter-dev

# 2. Setup ausführen
setup-jumpstarter.sh

# 3. Status prüfen
kubectl get pods -n jumpstarter-lab
kubectl get svc -n jumpstarter-lab

# 4. Exporter erstellen
uv run jmp admin create exporter test-exporter \
  --label environment=development \
  --save --insecure-tls-config

# 5. K9s Dashboard nutzen  
k9s -n jumpstarter-lab
```

## Troubleshooting

### Docker daemon nicht verfügbar
```bash
# Container mit privileged flag starten
docker run --rm -it --privileged the78mole/jumpstarter-dev
```

### Ports nicht erreichbar
```bash  
# Port-Mappings prüfen
docker ps
netstat -tlnp | grep :30010

# Services im Cluster prüfen
kubectl get svc -n jumpstarter-lab
```

### Jumpstarter startet nicht
```bash
# Pod Status prüfen
kubectl get pods -n jumpstarter-lab

# Logs anzeigen
kubectl logs -n jumpstarter-lab -l app.kubernetes.io/name=jumpstarter-controller
kubectl logs -n jumpstarter-lab -l app.kubernetes.io/name=jumpstarter-router
```

## Architektur

Dieses Setup nutzt:

- **Kind** für lokalen Kubernetes Cluster
- **Docker-in-Docker** für korrekte Port-Mappings
- **NGINX Ingress** für Web-Zugriff  
- **Helm** für Jumpstarter Installation
- **NodePorts** für GRPC Services
- **UV** für Python Package Management

## Erweiterte Nutzung

### Persistent Storage
```bash
docker run --rm -it --privileged \
  -p 30010:30010 -p 30011:30011 \
  -v $(pwd)/workspace:/workspace \
  the78mole/jumpstarter-dev
```

### Custom Configuration  
```bash
# Eigene Kind-Konfiguration verwenden
docker run --rm -it --privileged \
  -v $(pwd)/my-kind-config.yaml:/etc/kind-config.yaml \
  the78mole/jumpstarter-dev setup-jumpstarter.sh
```

### Development Mode
```bash
# Mit Source-Code Mount für Entwicklung
docker run --rm -it --privileged \
  -p 30010:30010 -p 30011:30011 \
  -v $(pwd)/my-project:/workspace/my-project \
  the78mole/jumpstarter-dev
```

## CI/CD Integration

```yaml
# GitHub Actions Beispiel
name: Test Jumpstarter
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Jumpstarter Tests
        run: |
          docker run --rm --privileged \
            -v ${{ github.workspace }}:/workspace/code \
            the78mole/jumpstarter-dev \
            bash -c "setup-jumpstarter.sh && cd /workspace/code && uv run robot tests/"
```

## License

Dieses Image und die beinhalteten Scripts stehen unter der Apache 2.0 Lizenz.

## Support

- **Issues**: [GitHub Issues](https://github.com/the78mole/docker-images/issues)
- **Source**: [GitHub Repository](https://github.com/the78mole/docker-images)
- **Jumpstarter Docs**: [Jumpstarter Documentation](https://github.com/jumpstarter-dev)

## Changelog

### v1.0.0
- Initial release
- Docker-in-Docker support
- Complete Jumpstarter development environment
- Automatic setup script
- All tools pre-installed