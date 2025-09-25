#!/bin/bash
set -e

echo "🚀 DevContainer Initialization"
echo "=============================="

# Check if running as vscode user in DevContainer
if [ "$(whoami)" = "vscode" ] && [ -n "${REMOTE_CONTAINERS}" ]; then
    echo "📦 DevContainer detected, initializing Docker daemon..."
    
    # Start Docker daemon in background if not already running
    if ! docker info >/dev/null 2>&1; then
        echo "🐳 Starting Docker daemon..."
        sudo /usr/local/share/docker-init.sh bash &
        
        # Wait for Docker to be ready
        echo "⏳ Waiting for Docker daemon..."
        for i in {1..30}; do
            if docker info >/dev/null 2>&1; then
                echo "✅ Docker daemon is ready!"
                break
            fi
            sleep 1
            echo "  Attempt $i/30..."
        done
        
        if ! docker info >/dev/null 2>&1; then
            echo "❌ Docker daemon failed to start"
            exit 1
        fi
    else
        echo "✅ Docker daemon already running"
    fi
    
    echo ""
    echo "🎯 DevContainer Ready!"
    echo "====================="
    echo "Available commands:"
    echo "  setup-jumpstarter.sh   # Complete Jumpstarter setup"
    echo "  docker --version       # Test Docker"
    echo "  kubectl version        # Test kubectl"
    echo "  helm version           # Test Helm"
    echo ""
else
    echo "💡 Not in DevContainer mode, skipping Docker initialization"
fi