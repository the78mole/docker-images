#!/bin/bash

# KiCad Documentation Builder
# Builds Sphinx documentation for KiCad projects
# Usage: kicad_docs_build [project_dir]

set -e

PROJECT_DIR=$(realpath "${1:-.}")
DOCS_DIR="${PROJECT_DIR}/docs"

echo "🔧 KiCad Documentation Builder"
echo "================================"
echo "🔍 Project directory: $PROJECT_DIR"
echo "📁 Docs directory: $DOCS_DIR"

# Check if docs directory exists
if [ ! -d "$DOCS_DIR" ]; then
    echo "❌ No docs directory found in: $PROJECT_DIR"
    echo "💡 Expected structure: $PROJECT_DIR/docs/source/"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$DOCS_DIR/source" ]; then
    echo "❌ No docs/source directory found"
    echo "💡 Expected Sphinx source files in: $DOCS_DIR/source/"
    exit 1
fi

cd "$DOCS_DIR"

# Check if Sphinx dependencies are available
echo "📦 Checking Sphinx dependencies..."
if ! python3 -c "import sphinx, myst_parser, sphinx_rtd_theme" 2>/dev/null; then
    echo "❌ Sphinx dependencies not found!"
    echo "💡 Make sure you're using the kicaddev-cli container with documentation tools"
    exit 1
fi

echo "✅ All dependencies found!"

# Clean build directory
echo "🧹 Cleaning old build files..."
rm -rf build/

# Build HTML documentation
echo "🏗️  Building HTML documentation..."
sphinx-build -b html source build/html

# Success message
echo ""
echo "✅ Documentation successfully built!"
echo "📖 Open: file://$(pwd)/build/html/index.html"
echo ""
echo "🚀 To serve locally:"
echo "   sphinx-autobuild source build/html"