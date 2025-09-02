#!/bin/bash

# KiCad Documentation PDF Builder
# Builds PDF documentation for KiCad projects using Sphinx + LaTeX
# Usage: kicad_docs_pdf [project_dir]

set -e

PROJECT_DIR=$(realpath "${1:-.}")
DOCS_DIR="${PROJECT_DIR}/docs"

echo "🔧 KiCad PDF Documentation Builder"
echo "=================================="
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

# Check if LaTeX is available
echo "🔍 Checking LaTeX installation..."
if ! command -v pdflatex >/dev/null 2>&1; then
    echo "❌ LaTeX not found!"
    echo "💡 Make sure you're using the kicaddev-cli container with LaTeX support"
    exit 1
fi

echo "✅ LaTeX found!"

# Clean build directory
echo "🧹 Cleaning old build files..."
rm -rf build/latex/

# Build LaTeX documentation
echo "🏗️  Building LaTeX documentation..."
sphinx-build -b latex source build/latex

# Build PDF from LaTeX
echo "📄 Converting LaTeX to PDF..."
cd "$DOCS_DIR/build/latex" || exit 1
if ! make all-pdf; then
    echo "❌ Error: PDF compilation failed"
    exit 1
fi

# Success message
echo ""
echo "✅ PDF documentation successfully built!"
echo "📖 PDF file: $(find build/latex -name '*.pdf' | head -1)"
echo ""