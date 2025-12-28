# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Dockerhub: https://hub.docker.com/r/iamteacher/rails-start.base/tags
# GitHub Container Registry: https://github.com/the-teacher/rails-start/pkgs/container/rails-start.base
# =-0-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Name: rails-start.base
# Description: Base Image with the most common software
# 
# Visit: https://github.com/the-teacher/rails-start
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
FROM --platform=$TARGETPLATFORM $DEBIAN_VERSION

# Build arguments
ARG TARGETARCH
ARG BUILDPLATFORM
ARG TARGETPLATFORM

ENV TARGETARCH=${TARGETARCH}
ENV BUILDPLATFORM=${BUILDPLATFORM}
ENV TARGETPLATFORM=${TARGETPLATFORM}

RUN echo "$BUILDPLATFORM" > /BUILDPLATFORM
RUN echo "$TARGETARCH" > /TARGETARCH
RUN echo "$TARGETPLATFORM" > /TARGETPLATFORM

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install all required packages:
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#   - build-essential: Essential compilation tools (gcc, make, etc.)
#   - make: Build automation tool
#   - wget: Tool for non-interactive file downloads
#   - curl: Command line for transferring data with URL syntax
#   - telnet: Telnet client for network debugging
#   - net-tools: Network utilities (netstat)
#   - dnsutils: DNS utilities (dig, nslookup)
#   - openssh-client: SSH client for remote connections
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
#   - pkg-config: Helper tool for compiling applications and libraries
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
    dnsutils \
    openssh-client \
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
    pkg-config \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "--login", "-c"]