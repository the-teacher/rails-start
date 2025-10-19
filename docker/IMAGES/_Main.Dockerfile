# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Name: rails-start.main
# Description: Main Rails Image with additional software
# 
# Visit: https://github.com/the-teacher/rails-start
# Dockerhub: https://hub.docker.com/r/iamteacher/rails-start.main/tags
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

# Install common packages as root
USER root

# Install essential packages (not included in base image):
# DATABASES
# ---------------------------------------------------------------
# git - Version control system (required by many gems and Ruby tools)
# sqlite3 and libsqlite3-dev - for SQLite database support
# postgresql-client - PostgreSQL client utilities (psql, etc.)
# libpq-dev - PostgreSQL development libraries for pg gem compilation
# default-mysql-client - MySQL client utilities
# default-libmysqlclient-dev - MySQL development libraries for mysql2 gem compilation
# ---------------------------------------------------------------
# RUBY BUILD DEPENDENCIES
# ---------------------------------------------------------------
# libssl-dev - OpenSSL development libraries (required for Ruby compilation)
# libreadline-dev - Readline development libraries (required for Ruby REPL)
# zlib1g-dev - Zlib compression library development files (required for Ruby)
# libffi-dev - Foreign Function Interface library (required for fiddle gem and Ruby FFI)
# libyaml-dev - YAML parsing library (required for psych gem and Ruby YAML support)
# rustc - Rust compiler (required for YJIT - Ruby's Just-In-Time compiler)
# cargo - Rust package manager (required for YJIT)
# build-essential - C compiler and build tools (already in base, but essential for Ruby)
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
# JMALLOC - memory allocator to reduce fragmentation
# ---------------------------------------------------------------

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    sqlite3 \
    libsqlite3-dev \
    postgresql-client \
    libpq-dev \
    default-mysql-client \
    default-libmysqlclient-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libffi-dev \
    libyaml-dev \
    rustc \
    cargo \
    ufw \
    fail2ban \
    rsync \
    net-tools \
    tmux \
    logrotate \
    gnupg \
    lsb-release \
    ca-certificates \
    # JMALLOC - memory allocator to reduce fragmentation
    libjemalloc2 \
    # Link jemalloc to a common path for easy use on different architectures
    && ln -sf $(find /usr/lib -name libjemalloc.so.2 | head -n 1) /usr/lib/libjemalloc.so.2 \
    # Cleanup
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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

# https://www.ruby-lang.org/en/downloads/
ARG RUBY_VERSION=3.4.7
# https://rubygems.org/gems/rubygems-update/versions
ARG DEFAULT_GEM_VERSION=3.7.2

# https://nodejs.org/en/download
ARG NODE_VERSION=22.20.0
# https://www.npmjs.com/package/npm
ARG NPM_VERSION=11.6.1
# https://github.com/nvm-sh/nvm/releases
ARG NVM_VERSION=0.40.3

ENV RUBY_VERSION=${RUBY_VERSION}
ENV DEFAULT_GEM_VERSION=${DEFAULT_GEM_VERSION}

ENV NVM_VERSION=${NVM_VERSION}
ENV NPM_VERSION=${NPM_VERSION}
ENV NODE_VERSION=${NODE_VERSION}

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

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# RBENV (Ruby Version Manager) for having local Ruby for user
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

WORKDIR /home/rails

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc

ENV PATH="/home/rails/.rbenv/bin:/home/rails/.rbenv/shims:${PATH}"

# Configure rbenv to compile Ruby with YJIT support
# YJIT_OPTS - enables YJIT JIT compiler during Ruby build
# ZJIT is an alternative JIT compiler for Ruby, focused on reducing memory usage
# Example: ./configure "--prefix=$HOME/.rbenv/versions/X.Y.Z" --enable-shared --enable-yjit --with-ext=openssl,psy
ENV RUBY_CONFIGURE_OPTS="--enable-yjit"

# Note:
# See: https://docs.ruby-lang.org/en/master/zjit_md.html => "--enable-zjit=dev"

# Use direct binary path for rbenv commands to avoid PATH initialization issues in Docker
RUN ~/.rbenv/bin/rbenv install ${RUBY_VERSION}
RUN ~/.rbenv/bin/rbenv global ${RUBY_VERSION}

# Update gem system to the latest version
# https://rubygems.org/gems/rubygems-update/versions
RUN ~/.rbenv/shims/gem update --system ${DEFAULT_GEM_VERSION}

# Install default Ruby on Rails
RUN ~/.rbenv/shims/gem install rails --no-document

# Copy Ruby environment check script to rails user home directory
COPY --chown=rails:rails checks/ruby-env.sh /home/rails/ruby-env.sh

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Create app directory
RUN mkdir -p /home/rails/app

# YJIT is a new JIT compiler for Ruby that can significantly improve performance
# Enable YJIT (Ruby's Just-In-Time compiler) for better performance
ENV RUBY_YJIT_ENABLE=1
ENV RUBYOPT="--yjit"

# Set editor for rails credentials
ENV EDITOR="vim"

# Common use of jemalloc to reduce memory fragmentation
# TEST: LD_PRELOAD=/usr/lib/libjemalloc.so.2 ruby -e 'sleep 100' &
# TEST: cat /proc/$(pgrep ruby)/maps | grep jemalloc
# TEST: IRB: puts `grep jemalloc /proc/self/maps`
ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

# Working directory
WORKDIR /home/rails/app

# Default shell command
CMD ["/bin/bash", "-c", "-l"]
