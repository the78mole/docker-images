#!/bin/bash
set -e

echo "🚀 Setting up Jumpstarter Development Environment"
echo "================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress indicators
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Pre-flight checks
print_info "Pre-flight checks..."
echo "  Docker: $(docker --version 2>/dev/null || echo 'Not available')"
echo "  kubectl: $(kubectl version --client --short 2>/dev/null || echo 'Not available')"
echo "  Helm: $(helm version --short 2>/dev/null || echo 'Not available')"
echo "  Kind: $(kind version 2>/dev/null || echo 'Not available')"

# Wait for Docker daemon (if not already initialized by docker-init.sh)
print_info "Checking Docker daemon status..."

if docker info >/dev/null 2>&1; then
    print_success "Docker daemon is ready"
else
    print_info "Docker daemon not ready, waiting..."
    MAX_ATTEMPTS=30
    ATTEMPT=1

    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
        if docker info >/dev/null 2>&1; then
            print_success "Docker daemon is ready"
            break
        fi
        echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS: Docker not ready, waiting..."
        sleep 2
        ((ATTEMPT++))
    done

    if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
        print_error "Docker daemon not available. Please run with --privileged flag."
        print_error "Or start Docker daemon manually: dockerd --host=unix:///var/run/docker.sock"
        exit 1
    fi
fi

# Create Kind cluster if it doesn't exist
CLUSTER_NAME="jumpstarter-server"
print_info "Setting up Kind cluster..."

if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    print_info "Creating new Kind cluster: $CLUSTER_NAME"
    
    # Use custom kind config if available, otherwise create default
    KIND_CONFIG="/etc/kind-config.yaml"
    if [ ! -f "$KIND_CONFIG" ]; then
        print_info "Creating default Kind configuration..."
        cat > /tmp/kind-config.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: jumpstarter-server
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 5080
        protocol: TCP
      - containerPort: 443
        hostPort: 5443
        protocol: TCP
      - containerPort: 30010
        hostPort: 30010
        protocol: TCP
      - containerPort: 30011
        hostPort: 30011
        protocol: TCP
      - containerPort: 8082
        hostPort: 8082
        protocol: TCP
      - containerPort: 8083
        hostPort: 8083
        protocol: TCP
EOF
        KIND_CONFIG="/tmp/kind-config.yaml"
    fi
    
    kind create cluster --config="$KIND_CONFIG" --wait=300s
    print_success "Kind cluster created successfully"
else
    print_info "Kind cluster '$CLUSTER_NAME' already exists"
fi

# Configure kubectl
print_info "Configuring kubectl..."
mkdir -p ~/.kube /home/jumpstarter/.kube
kind export kubeconfig --name "$CLUSTER_NAME"
cp ~/.kube/config /home/jumpstarter/.kube/config 2>/dev/null || true

# Wait for cluster to be ready
print_info "Waiting for cluster nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install NGINX Ingress Controller
print_info "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

print_info "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

# Install Jumpstarter via Helm
print_info "Installing Jumpstarter via Helm..."

# Create namespace
kubectl create namespace jumpstarter-lab --dry-run=client -o yaml | kubectl apply -f -

# Set up Jumpstarter configuration
export IP="127.0.0.1"
export BASEDOMAIN="jumpstarter.${IP}.nip.io"
export GRPC_ENDPOINT="grpc.${BASEDOMAIN}:8082"
export GRPC_ROUTER_ENDPOINT="router.${BASEDOMAIN}:8083"

# Install Jumpstarter using Helm
if ! helm list -A | grep -q jumpstarter; then
    print_info "Installing Jumpstarter Helm chart..."
    
    helm upgrade jumpstarter --install oci://quay.io/jumpstarter-dev/helm/jumpstarter \
        --create-namespace --namespace jumpstarter-lab \
        --set global.baseDomain="${BASEDOMAIN}" \
        --set jumpstarter-controller.grpc.endpoint="${GRPC_ENDPOINT}" \
        --set jumpstarter-controller.grpc.routerEndpoint="${GRPC_ROUTER_ENDPOINT}" \
        --set global.metrics.enabled=false \
        --set jumpstarter-controller.grpc.nodeport.enabled=true \
        --set jumpstarter-controller.grpc.mode=ingress \
        --version=0.7.0-dev-8-g83e23d3
    
    print_success "Jumpstarter Helm chart installed"
else
    print_info "Jumpstarter is already installed"
fi

# Wait for Jumpstarter pods
print_info "Waiting for Jumpstarter pods to be ready..."
MAX_WAIT=60
WAIT_COUNT=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    RUNNING_PODS=$(kubectl get pods -n jumpstarter-lab --no-headers 2>/dev/null | grep -c "Running" 2>/dev/null || echo "0")
    TOTAL_PODS=$(kubectl get pods -n jumpstarter-lab --no-headers 2>/dev/null | grep -v "^$" | wc -l 2>/dev/null || echo "0")
    
    # Clean up variables
    RUNNING_PODS=$(echo "$RUNNING_PODS" | tr -d '\n' | tr -d ' ')
    TOTAL_PODS=$(echo "$TOTAL_PODS" | tr -d '\n' | tr -d ' ')
    
    # Default to 0 if not a number
    [ "$RUNNING_PODS" -eq "$RUNNING_PODS" ] 2>/dev/null || RUNNING_PODS=0
    [ "$TOTAL_PODS" -eq "$TOTAL_PODS" ] 2>/dev/null || TOTAL_PODS=0
    
    if [ "$RUNNING_PODS" -gt 0 ] && [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
        print_success "All Jumpstarter pods are running ($RUNNING_PODS/$TOTAL_PODS)"
        break
    fi
    
    echo "  Waiting for pods... ($RUNNING_PODS/$TOTAL_PODS running)"
    sleep 5
    ((WAIT_COUNT+=5))
done

# Setup Python environment with UV
print_info "Setting up Python environment..."
if command -v uv >/dev/null 2>&1; then
    cd /workspace
    if [ -f "pyproject.toml" ]; then
        print_info "Installing Python dependencies with UV..."
        uv sync 2>/dev/null || print_warning "UV sync completed with warnings"
        
        print_info "Installing Jumpstarter CLI dependencies..."
        uv pip install jumpstarter-cli jumpstarter-driver-opendal jumpstarter-driver-power jumpstarter-driver-composite 2>/dev/null || print_warning "Some dependencies may need manual installation"
    fi
    print_success "Python environment configured"
else
    print_warning "UV not found - install via: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# Final status check
print_info "Final system status check..."
echo ""
echo "=== Cluster Status ==="
kubectl get nodes -o wide

echo ""
echo "=== Jumpstarter Pods ==="
kubectl get pods -n jumpstarter-lab

echo ""
echo "=== Services ==="
kubectl get svc -n jumpstarter-lab

echo ""
echo "=== Ingress ==="
kubectl get ingress -n jumpstarter-lab 2>/dev/null || echo "No ingress resources found"

echo ""
echo "=== 🎉 Setup Complete! ==="
print_success "Jumpstarter Development Environment is ready!"
echo ""
echo "🔗 Access Information:"
echo "  GRPC Controller:     localhost:30010 (NodePort)"
echo "  GRPC Router:         localhost:30011 (NodePort)"
echo "  Ingress Controller:  localhost:5080 (HTTP)"
echo "  Base Domain:         jumpstarter.127.0.0.1.nip.io"
echo ""
echo "📋 Next Steps:"
echo "  1. Check pod status: kubectl get pods -n jumpstarter-lab"
echo "  2. View logs: kubectl logs -n jumpstarter-lab -l app.kubernetes.io/name=jumpstarter-controller"
echo "  3. Use k9s dashboard: k9s -n jumpstarter-lab"
echo "  4. Create exporter: uv run jmp admin create exporter test-exporter"
echo ""
echo "🐍 Python CLI Usage:"
echo "  uv run jmp --help"
echo "  uv run jmp admin --help"
echo "  uv run jmp admin get --help"
echo ""
echo "🔧 Troubleshooting:"
echo "  If services are not accessible, check NodePort mappings:"
echo "  kubectl get svc -n jumpstarter-lab"
echo ""
print_success "Happy Jumpstarter development! 🚀"