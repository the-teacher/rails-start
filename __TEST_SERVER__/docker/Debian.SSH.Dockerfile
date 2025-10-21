# Debian Docker image with SSH server
FROM debian:bullseye-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Installing packages:
# - openssh-server: SSH daemon for remote access
# - sudo: allows users to run commands as other users
# - curl: command line tool for transferring data with URLs
# - wget: utility for non-interactive download of files from web
# - vim: advanced text editor
# - nano: simple text editor
# - htop: interactive process viewer
# - net-tools: networking utilities (ifconfig, netstat, etc.)
# - iputils-ping: ping utility for network connectivity testing
# - iptables: netfilter administration tool for packet filtering and NAT
# - ufw: uncomplicated firewall - easy-to-use frontend for iptables

# Update package list and install SSH server and essential packages
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    vim \
    nano \
    htop \
    net-tools \
    iputils-ping \
    iptables \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create SSH host keys
RUN ssh-keygen -A

# Create the privilege separation directory
RUN mkdir -p /var/run/sshd

# Configure SSH for passwordless access (testing only!)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config && \
    echo 'UsePAM no' >> /etc/ssh/sshd_config

# Set empty root password (allows login without password)
RUN passwd -d root

# Expose SSH port
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]