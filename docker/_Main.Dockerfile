# Using base image instead of Ubuntu
FROM iamteacher/rails-start.base:latest

# Working directory
WORKDIR /home/rails/app

# YJIT is a new JIT compiler for Ruby that can significantly improve performance
# Enable YJIT (Ruby's Just-In-Time compiler) for better performance
ENV RUBY_YJIT_ENABLE=1
ENV RUBYOPT="--yjit"

# Install common packages as root
USER root

# Install essential packages:
# less - for viewing files
# ufw - for basic security
# fail2ban - intrusion prevention system
# rsync - for file synchronization
# zip/unzip - for archive management
# ncdu - disk usage analyzer
# tree - directory structure viewer
# net-tools - network utilities (netstat)
# tmux - virtual terminals for keeping sessions alive
# cron - task scheduler
# logrotate - log rotation utility
# curl - for downloading files
# gnupg - for GPG keys
# ca-certificates - for HTTPS
# lsb-release - for distribution information
# make - build automation tool
# sqlite3 and libsqlite3-dev - for SQLite database support

RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-dev \
    less \
    ufw \
    fail2ban \
    rsync \
    zip \
    unzip \
    ncdu \
    tree \
    net-tools \
    tmux \
    cron \
    logrotate \
    curl \
    gnupg \
    lsb-release \
    make \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Rails user is already created in the base image and has access to the /app directory
USER rails:rails

# Update gem system to the latest version
# https://rubygems.org/gems/rubygems-update/versions
RUN gem update --system 3.7.2

# Installing required gems for the blog
RUN gem install rails

WORKDIR /home/rails/app

# Default command
CMD ["bash"]
