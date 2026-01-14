# LaTeX + Node.js Development Environment

A Docker image combining LaTeX/TeXLive with Node.js for projects requiring both document generation and JavaScript tooling.

## Features

- **Complete TeXLive**: Full LaTeX distribution with all packages
- **Node.js LTS**: Latest stable Node.js with npm
- **Document Tools**: Mermaid CLI, markdown-pdf, reveal-md
- **TypeScript Support**: TypeScript compiler and tooling  
- **Build Tools**: latexmk, biber, fontconfig
- **Development Environment**: Python 3, build-essential

## Quick Start

### Build the image

```bash
docker build -t latex-node .
```

### Run interactive session

```bash
docker run -it --rm -v $(pwd):/workspace latex-node
```

### Compile LaTeX documents

```bash
# Inside container
pdflatex document.tex
latexmk -pdf document.tex
xelatex document.tex
```

### Node.js development

```bash
# Initialize Node.js project
npm init -y
npm install express

# TypeScript project
tsc --init
npm install typescript @types/node
```

## Use Cases

### Academic Papers with Diagrams

```bash
# Generate Mermaid diagrams
mmdc -i flowchart.mmd -o flowchart.png

# Compile LaTeX with generated images
pdflatex paper.tex
```

### Presentation Workflows

```bash
# Create reveal.js presentations
reveal-md slides.md --theme sky --static _site

# Convert Markdown to PDF
markdown-pdf README.md
```

### Documentation Pipelines

```bash
# TypeScript documentation generator
npm install typedoc
npx typedoc src/

# LaTeX documentation
latexmk -pdf manual.tex
```

## Pre-installed Global Packages

- `typescript` - TypeScript compiler
- `@mermaid-js/mermaid-cli` - Diagram generation
- `markdown-pdf` - Markdown to PDF conversion
- `reveal-md` - Reveal.js presentation tool
- `@playwright/test` - Browser automation
- `nodemon` - Development file watcher

## Environment Variables

- `LANG=en_US.UTF-8` - Locale configuration
- Development user: `latexnode`
- Working directory: `/workspace`

## Commands

Run `latex-node-help` inside the container for a comprehensive command reference.

### LaTeX Commands

- `pdflatex`, `xelatex`, `lualatex` - LaTeX compilers
- `latexmk -pdf` - Automated compilation
- `biber` - Bibliography processor

### Node.js Commands

- `node`, `npm` - JavaScript runtime and package manager
- `tsc` - TypeScript compiler
- `mmdc` - Mermaid diagram CLI

## Volume Mounts

Mount your project directory to `/workspace`:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  latex-node
```

## Version

Current version: 1.0.0

## License

This Docker image packages open-source tools. Individual tools maintain their respective licenses.