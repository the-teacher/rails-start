# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Name: rails-start.main
# Description: Main Rails Image with additional software
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
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Using base image instead of Ubuntu
FROM iamteacher/rails-start.base:latest

# https://nodejs.org/en/download
ARG NODE_VERSION=22.20.0
ENV NODE_VERSION=${NODE_VERSION}
# https://www.npmjs.com/package/npm
ARG NPM_VERSION=11.6.1
# https://github.com/nvm-sh/nvm/releases
ARG NVM_VERSION=0.40.3
ENV NVM_VERSION=${NVM_VERSION}

# Install common packages as root
USER root

# Install essential packages (not included in base image):
# DATABASES
# ---------------------------------------------------------------
# sqlite3 and libsqlite3-dev - for SQLite database support
# postgresql-client - PostgreSQL client utilities (psql, etc.)
# libpq-dev - PostgreSQL development libraries for pg gem compilation
# default-mysql-client - MySQL client utilities
# default-libmysqlclient-dev - MySQL development libraries for mysql2 gem compilation
# ---------------------------------------------------------------
# ufw - for basic security
# fail2ban - intrusion prevention system
# rsync - for file synchronization
# net-tools - network utilities (netstat)
# tmux - virtual terminals for keeping sessions alive
# logrotate - log rotation utility
# gnupg - for GPG keys
# lsb-release - for distribution information
# ca-certificates - for HTTPS

RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    postgresql-client \
    libpq-dev \
    default-mysql-client \
    default-libmysqlclient-dev \
    ufw \
    fail2ban \
    rsync \
    net-tools \
    tmux \
    logrotate \
    gnupg \
    lsb-release \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Update gem system to the latest version as root (requires system permissions)
# https://rubygems.org/gems/rubygems-update/versions
RUN gem update --system 3.7.2

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Rails User Setup
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Create rails user and group with ID 1000
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Add rails to sudo group and configure passwordless sudo
# RUN usermod -aG sudo rails && \
#     echo "rails ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rails

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Rails user
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

USER rails:rails

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# NODE.JS (Local version for rails user)
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RUN mkdir -p /home/rails/.nvm
ENV NVM_DIR="/home/rails/.nvm"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && npm install -g npm@${NPM_VERSION}
RUN . "$NVM_DIR/nvm.sh" && npm install -g yarn@latest
RUN . "$NVM_DIR/nvm.sh" && npm install -g svgo

# Add NVM binaries to PATH
ENV PATH="/home/rails/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Create app directory
RUN mkdir -p /home/rails/app

# Set editor for rails credentials
ENV EDITOR="vim"

# Gem Settings
# Install user-specific gems to avoid permission issues
ENV GEM_HOME="/home/rails/.gem"
ENV PATH="$GEM_HOME/bin:$PATH"

# Bundler Settings
# Install gems to the user directory
# To have a better control over gem versions per project
# Disable the local cache of gems
ENV BUNDLE_PATH=/home/rails/.bundle
ENV BUNDLE_DISABLE_SHARED_GEMS=true
ENV BUNDLE_NO_CACHE=false

# YJIT is a new JIT compiler for Ruby that can significantly improve performance
# Enable YJIT (Ruby's Just-In-Time compiler) for better performance
ENV RUBY_YJIT_ENABLE=1
ENV RUBYOPT="--yjit"

# ZJIT is an alternative JIT compiler for Ruby, focused on reducing memory usage
# Uncomment the following lines to enable ZJIT instead of YJIT
# ENV RUBY_ZJIT_ENABLE=1
# ENV RUBYOPT="--zjit"

# Working directory
WORKDIR /home/rails/app

# Install Ruby on Rails
RUN gem install rails --no-document

# Default command
CMD ["bash"]
