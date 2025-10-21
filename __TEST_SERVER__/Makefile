# Makefile for Debian SSH Server management

# Docker Compose file path
COMPOSE_FILE = docker/docker-compose.yml

# SSH Server port
SSH_PORT = 2222

# Include separate makefiles
include ./Makefiles/aliases.mk
include ./Makefiles/server.mk

# Default target
help:
	@echo "🚀 Debian SSH Server Management System"
	@echo "======================================"
	@echo ""
	@echo "=== Help Commands ==="
	@echo "  make help-server     - Show server management commands"
	@echo "  make help-ssh        - Show SSH and script commands"
	@echo "  make help-ssh-keys   - Show SSH key management commands"
	@echo "  make help-deploy     - Show deployment automation commands"
	@echo "  make help-aliases    - Show short command aliases"
	@echo ""
	@echo "=== Quick Start ==="
	@echo "  make start      - Start the server"
	@echo "  make ssh        - Connect to server"
	@echo "  make deploy     - Full deployment"
	@echo ""
	@echo "=== Connection Info ==="
	@echo "  ROOT password: rootpassword"
	@echo "  SSH: ssh root@localhost -p $(SSH_PORT)"
	@echo ""
	@echo "  RAILS password: railspassword"
	@echo "  SSH: ssh rails@localhost -p $(SSH_PORT)"
	@echo ""