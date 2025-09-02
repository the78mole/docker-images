#!/bin/bash
set -e

# Function to setup permissions
setup_permissions() {
    mkdir -p /workspace
    chmod -R 755 /workspace
    
    # Ensure all tools are accessible
    chmod +x /usr/local/bin/kicad_export 2>/dev/null || true
    chmod +x /usr/local/bin/generate_ibom_headless 2>/dev/null || true
    chmod +x /usr/local/bin/kicad_docs_build 2>/dev/null || true
    chmod +x /usr/local/bin/kicad_docs_pdf 2>/dev/null || true
    chmod +x /usr/local/bin/kicad_docs_init 2>/dev/null || true
}

# If running as root
if [ "$EUID" -eq 0 ]; then
    echo "Running as root..."
    
    # Always setup permissions
    setup_permissions
    
    # If this is GitHub Actions, stay as root for compatibility
    if [ "${GITHUB_ACTIONS}" = "true" ]; then
        echo "GitHub Actions detected - running as root"
        
        # If there's a specific user ID from the environment, adjust kicad user
        if [ -n "${RUNNER_UID}" ]; then
            usermod -u ${RUNNER_UID} kicad 2>/dev/null || true
        fi
        if [ -n "${RUNNER_GID}" ]; then
            groupmod -g ${RUNNER_GID} kicad 2>/dev/null || true
        fi
        
        # Execute as root
        exec "$@"
    else
        # For non-GitHub Actions usage, switch to kicad user for security
        echo "Non-CI environment - switching to kicad user"
        chown -R kicad:kicad /workspace
        exec gosu kicad "$@"
    fi
else
    # Not running as root, just execute
    echo "Running as non-root user: $(whoami)"
    exec "$@"
fi