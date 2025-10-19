# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Name: rails-start.base
# Description: Base Image with the most common software
# 
# Visit: https://github.com/the-teacher/rails-start
# Dockerhub: https://hub.docker.com/r/iamteacher/rails-start.base/tags
# Author: Ilya Zykin (https://github.com/the-teacher)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Rails Start - Fast Track to Rails Development
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Visit: https://github.com/the-teacher/rails-start
# 
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=====

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Software versions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Debian version to use
ARG DEBIAN_VERSION=debian:bookworm

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# STAGE | MAIN
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
FROM --platform=$BUILDPLATFORM $DEBIAN_VERSION

# Build arguments
ARG TARGETARCH
ARG BUILDPLATFORM

ENV TARGETARCH=${TARGETARCH}
ENV BUILDPLATFORM=${BUILDPLATFORM}


RUN echo "$BUILDPLATFORM" > /BUILDPLATFORM
RUN echo "$TARGETARCH" > /TARGETARCH

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install all required packages:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#   - build-essential: Essential compilation tools (gcc, make, etc.)
#   - make: Build automation tool
#   - wget: Tool for non-interactive file downloads
#   - curl: Command line for transferring data with URL syntax
#   - telnet: Telnet client for network debugging
#   - net-tools: Network utilities (netstat)
#   - bash: Bourne Again SHell
#   - vim: Improved vi text editor
#   - nano: Simple text editor
#   - cron: Process scheduling daemon
#   - procps: System and process monitoring utilities
#   - htop: Enhanced process monitoring with interactive interface
#   - tree: Displays directory structure in a tree-like format
#   - sudo: Allows a permitted user to execute a command as the superuser
#   - ncdu: Disk usage analyzer with interactive interface
#   - jq: Command-line JSON processor
#   - less: Pager for viewing files
#   - unzip/zip: Archive utilities for ZIP files
#   - tar: Archive utility for TAR files
#   - gzip: Compression utility
#   - file: Determines file type
#   - lsof: Lists open files and processes
#   - ca-certificates: Common CA certificates for HTTPS (here for node/npm)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    make \
    # Network tools
    wget \
    curl \
    telnet \
    net-tools \
    # Shell
    bash \
    # Text editors
    vim \
    nano \
    # System tools
    cron \
    procps \
    htop \
    tree \
    sudo \
    ncdu \
    # File and text utilities
    jq \
    less \
    unzip \
    zip \
    tar \
    gzip \
    file \
    lsof \
    # SSL/TLS certificates
    ca-certificates \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "--login", "-c"]

# https://nodejs.org/en/download
# ARG NODE_VERSION=22.20.0
# https://www.npmjs.com/package/npm
# ARG NPM_VERSION=11.6.1
# https://github.com/nvm-sh/nvm/releases
# ARG NVM_VERSION=0.40.3
# ENV NODE_VERSION=${NODE_VERSION}
# ENV NPM_VERSION=${NPM_VERSION}
# ENV NVM_VERSION=${NVM_VERSION}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# NODE.JS (Global version for all users)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# ENV NVM_DIR="/opt/.nvm"
# RUN mkdir -p /opt/.nvm

# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
# RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && nvm use ${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && npm install -g npm@${NPM_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && npm install -g yarn@latest
# RUN . "$NVM_DIR/nvm.sh" && npm install -g svgo

# Add NVM binaries to PATH
# ENV PATH="/opt/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"