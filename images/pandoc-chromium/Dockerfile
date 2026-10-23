# Pandoc + Chromium (headless) zum Rendern von Markdown nach PDF in CI-Jobs,
# z. B. als `container:` in GitHub Actions. Debian statt Ubuntu, weil Ubuntu
# Chromium nur als Snap ausliefert.
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    CHROME=/usr/bin/chromium

# git: Stand/Version aus der Historie; gh: Upload an GitHub-Releases;
# ca-certificates/curl: HTTPS in Actions-Schritten.
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    chromium \
    fonts-dejavu-core \
    git \
    gh \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Als root, damit actions/checkout und Schreibzugriffe im Workspace ohne
# Rechteanpassung funktionieren. Chromium daher mit --no-sandbox starten.
WORKDIR /workspace
CMD ["bash"]
