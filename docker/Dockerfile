FROM ubuntu:20.04
LABEL Author="Daniel Duclos-Cavalcanti"
LABEL Email="daniel.duclos-cavalcanti@gmail.com"
LABEL Maintainer="Daniel Duclos-Cavalcanti"
LABEL remarks="Dockerfile for LiberoSoC"

ARG DISPLAY
ARG DEBIAN_FRONTEND=noninteractive
ENV GEOMETRY 1920x1080

# Base System
RUN apt-get update \
    && apt-get install -y \
        build-essential default-jre gcc-multilib git \
        xorg tightvncserver \
        libxrender-dev libxtst-dev apt-file lsb \
        wget curl vim tmux nano \
        sudo locales gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Language
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && update-locale

# File System
RUN mkdir -p /home/docker/software
COPY software /home/docker/software

RUN mkdir -p /home/docker/license
COPY license /home/docker/license

RUN mkdir -p /home/docker/repo
COPY install.sh /home/docker/

# Install Libero, SoftConsole and
RUN ln -s /tmp /usr/tmp
RUN /home/docker/install.sh

WORKDIR /home/docker
