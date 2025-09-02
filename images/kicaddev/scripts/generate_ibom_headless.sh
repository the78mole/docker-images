#!/bin/bash
# Wrapper script for headless InteractiveHtmlBom generation

# Start virtual display if not already running
if ! pgrep -f "Xvfb" > /dev/null; then
    Xvfb :99 -screen 0 1024x768x24 &
    XVFB_PID=$!
fi

# Set display
export DISPLAY=:99

# Convert relative paths to absolute paths to avoid path duplication issues
if [ $# -gt 0 ] && [ -f "$1" ]; then
    PCB_FILE=$(realpath "$1")
    shift
    generate_interactive_bom "$PCB_FILE" "$@"
else
    generate_interactive_bom "$@"
fi
RESULT=$?

# Clean up if we started Xvfb
if [ ! -z "$XVFB_PID" ]; then
    kill $XVFB_PID 2>/dev/null || true
fi

exit $RESULT