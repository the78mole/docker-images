FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ARDUINO_CLI_VERSION=0.35.3

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

# Basis-Tools installieren
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    ca-certificates \
    git \
    sudo \
    python3 \
    python3-pip \
    python3-serial \
    && rm -rf /var/lib/apt/lists/*

# Arduino CLI installieren
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh && \
    mv bin/arduino-cli /usr/local/bin/arduino-cli

# Benutzer mit definierter UID/GID anlegen
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

RUN pip install --break-system-packages pre-commit

# Arbeitsverzeichnis und Nutzer setzen
WORKDIR /home/${USERNAME}
USER ${USERNAME}

# Standardkommando
CMD ["arduino-cli"]