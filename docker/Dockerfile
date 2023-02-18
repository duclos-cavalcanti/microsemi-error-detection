FROM ubuntu:22-04
LABEL Author="Daniel Duclos-Cavalcanti"
LABEL Email="daniel.duclos-cavalcanti@gmail.com"
LABEL Maintainer="Daniel Duclos-Cavalcanti"
LABEL remarks="Dockerfile for LiberoSoC"

# Base System
RUN apt-get update \
    && apt-get install -y \
        xorg vnc4server \
        libxrender-dev \
        libxtst-dev \
        build-essential \
        default-jre \
        gcc-multilib git \
        wget curl vim tmux nano \
        sudo locales gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Language
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && update-locale

# Install Libero 12.4
RUN cd /tmp \
    && wget "http://127.0.0.1:8765/Libero_SoC_v12.4_lin.bin" && \
    chmod +x Libero_SoC_v12.4_lin.bin && \
    TERM=xterm ./Libero_SoC_v12.4_lin.bin -i silent && \
    rm Libero_SoC_v12.4_lin.bin #&& \

ENV DISPLAY :0
ENV GEOMETRY 1920x1080

WORKDIR /home/project
ENTRYPOINT ["./docker/entry.sh"]
