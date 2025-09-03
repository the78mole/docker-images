FROM ghcr.io/the78mole/arduino-cli:latest

ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

RUN arduino-cli config init \
    && arduino-cli config add board_manager.additional_urls \
       https://espressif.github.io/arduino-esp32/package_esp32_dev_index.json \
       http://arduino.esp8266.com/stable/package_esp8266com_index.json \
    && arduino-cli core update-index \
    && arduino-cli core install esp8266:esp8266 \
    && arduino-cli core install esp32:esp32@3.0.7 \
    && arduino-cli lib install ringbuffer pubsubclient arduinojson dallastemperature onewire "Adafruit NeoPixel"

# Arbeitsverzeichnis und Nutzer setzen
WORKDIR /home/${USERNAME}
USER ${USERNAME}

# Standardkommando
CMD ["arduino-cli", "version"]