# LaTeX + Node.js Development Environment  
FROM ubuntu:latest

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Set up locale
RUN apt-get update && apt-get install -y \
    locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install system dependencies (ubuntu:latest has many tools pre-installed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    fontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install LaTeX (TeXLive full scheme)
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-full \
    latexmk \
    biber \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install common global npm packages for document workflows
RUN npm install -g \
    typescript \
    @mermaid-js/mermaid-cli \
    markdown-pdf \
    puppeteer \
    @playwright/test \
    reveal-md \
    nodemon

# Create development user
RUN groupadd -r latexnode && useradd -r -g latexnode -m -d /home/latexnode -s /bin/bash latexnode

# Create workspace directory
RUN mkdir -p /workspace && chown latexnode:latexnode /workspace

# Configure sudo for latexnode user
RUN apt-get update && apt-get install -y --no-install-recommends sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "latexnode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add helpful environment setup and aliases
RUN echo 'export PATH="/home/latexnode/.local/bin:$PATH"' >> /etc/bash.bashrc \
    && echo '#!/bin/bash\necho "LaTeX + Node.js Commands:"\necho "LaTeX:"\necho "  pdflatex document.tex"\necho "  xelatex document.tex"\necho "  lualatex document.tex"\necho "  latexmk -pdf document.tex"\necho "  biber bibliography"\necho ""\necho "Node.js:"\necho "  node --version && npm --version"\necho "  npm init"\necho "  npm install <package>"\necho "  npm run <script>"\necho ""\necho "Document Tools:"\necho "  mmdc -i diagram.mmd -o diagram.png    # Mermaid diagrams"\necho "  markdown-pdf README.md               # Markdown to PDF"\necho "  reveal-md slides.md --theme sky      # Reveal.js presentations"\necho "  tsc --init                           # TypeScript project"' > /usr/local/bin/latex-node-help \
    && chmod +x /usr/local/bin/latex-node-help

# Set working directory and switch to development user
WORKDIR /workspace
RUN chown -R latexnode:latexnode /workspace /home/latexnode

# Switch to development user
USER latexnode

# Default command shows available tools
CMD ["bash", "-c", "echo 'LaTeX + Node.js Development Environment'; echo ''; echo 'Available tools:'; pdflatex --version | head -1; echo -n 'Node.js: '; node --version; echo -n 'npm: '; npm --version; echo ''; echo 'Use latex-node-help for common commands'"]