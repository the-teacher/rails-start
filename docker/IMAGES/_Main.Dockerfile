# Visit: https://github.com/the-teacher/rails-start

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

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# https://hub.docker.com/r/iamteacher/rails-start.main/tags
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Main Image with additional software
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Using base image instead of Ubuntu
FROM iamteacher/rails-start.base:latest

# Working directory
WORKDIR /home/rails/app

# YJIT is a new JIT compiler for Ruby that can significantly improve performance
# Enable YJIT (Ruby's Just-In-Time compiler) for better performance
ENV RUBY_YJIT_ENABLE=1
ENV RUBYOPT="--yjit"

# ZJIT is an alternative JIT compiler for Ruby, focused on reducing memory usage
# Uncomment the following lines to enable ZJIT instead of YJIT
# ENV RUBY_ZJIT_ENABLE=1
# ENV RUBYOPT="--zjit"

# Install common packages as root
USER root

# Install essential packages (not included in base image):
# sqlite3 and libsqlite3-dev - for SQLite database support
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

# Give rails user access to bundle directory
RUN chown -R rails:rails /usr/local/bundle

# Switch to rails user
USER rails:rails

# Installing required gems
RUN gem install rails

WORKDIR /home/rails/app

# Default command
CMD ["bash"]
