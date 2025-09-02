FROM ubuntu:noble

# Label will be set during build via --label flag
# LABEL org.opencontainers.image.source will be added during CI build
ENV DEBIAN_FRONTEND=noninteractive

# Systempakete installieren - nur die essentiellen für PlatformIO
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    udev \
    shellcheck \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add vscode user
RUN if ! getent group 1000; then \
      groupadd --gid 1000 vscode; \
    fi && \
    if ! id -u 1000 > /dev/null 2>&1; then \
      useradd --uid 1000 --gid 1000 -m vscode; \
    fi

# PlatformIO installieren
RUN pip3 install --break-system-packages \
    platformio==6.1.18 \
    pre-commit==4.2.0 \
    esptool==5.0.1

# PlatformIO Udev-Regeln installieren (für USB-Geräte)
RUN curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules \
    -o /etc/udev/rules.d/99-platformio-udev.rules

# Standard-Arbeitsverzeichnis
WORKDIR /workspace