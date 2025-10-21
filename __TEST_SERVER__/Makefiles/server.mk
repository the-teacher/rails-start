# Server management commands via Docker

# Help for server commands
help-server:
	@echo "=== Server Management Commands ==="
	@echo "  make server-start           - Start the SSH server container"
	@echo "  make server-stop            - Stop the SSH server container"
	@echo "  make server-restart         - Restart the SSH server container"
	@echo "  make server-build           - Build the SSH server image"
	@echo "  make server-rebuild         - Rebuild the SSH server image from scratch"
	@echo "  make server-clean           - Stop and remove containers, volumes, and images"
	@echo "  make server-clean-ssh-keys  - Remove SSH host key from known_hosts"
	@echo "  make server-status          - Show SSH server container status"
	@echo "  make server-shell           - Get shell access to the running container (as root)"
	@echo "  make server-rails-shell     - Get shell access to the running container (as rails user)"
	@echo "  make server-ssh             - Connect to the SSH server via SSH (password auth as root)"
	@echo "  make server-ssh-rails       - Connect to the SSH server via SSH (password auth as rails)"
	@echo "  make server-ssh-shell       - Connect to the SSH server via SSH (key auth as root)"
	@echo "  make server-ssh-rails-shell - Connect to the SSH server via SSH (key auth as rails)"
	@echo "  make prepare                - Create necessary files"
	@echo ""

# Get shell access to the running container (as root)
server-shell:
	@echo "Connecting to SSH server container..."
	docker-compose -f $(COMPOSE_FILE) exec debian-server /bin/bash

# Get shell access to the running container (as rails user)
server-rails-shell:
	@echo "Connecting to SSH server container as rails user..."
	docker-compose -f $(COMPOSE_FILE) exec -u rails debian-server /bin/bash

# Connect via SSH using keys (as rails user)
server-ssh-rails-shell:
	@echo "Ensure SSH keys are set up correctly."
	@echo "Connecting via SSH as rails user..."
	ssh -i $(SSH_KEYS_DIR)/$(KEY_NAME) rails@localhost -p $(SSH_PORT)

# Connect via SSH (password authentication as root)
server-ssh:
	@echo "Connecting via SSH..."
	@echo "Password: rootpassword"
	ssh root@localhost -p $(SSH_PORT)

# Connect via SSH (password authentication as rails user)
server-ssh-rails:
	@echo "Connecting via SSH as rails user..."
	@echo "Password: railspassword"
	ssh rails@localhost -p $(SSH_PORT)

# Connect via SSH using keys (as root)
server-ssh-shell:
	@echo "Ensure SSH keys are set up correctly."
	@echo "Connecting via SSH as root using keys..."
	ssh -i $(SSH_KEYS_DIR)/$(KEY_NAME) root@localhost -p $(SSH_PORT)

# Start the SSH server
server-start:
	make prepare
	@echo "Starting Debian SSH server..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "SSH server is running on port $(SSH_PORT)"
	@echo "Connect with: ssh root@localhost -p $(SSH_PORT)"

# Stop the SSH server
server-stop:
	@echo "Stopping Debian SSH server..."
	docker-compose -f $(COMPOSE_FILE) down

server-down:
	make server-stop

# Restart the SSH server
server-restart:
	@echo "Restarting Debian SSH server..."
	make server-stop
	make server-start

# Build the SSH server image
server-build:
	@echo "Building Debian SSH server image..."
	docker-compose -f $(COMPOSE_FILE) build --no-cache

# Rebuild the SSH server image from scratch
server-rebuild:
	make server-clean-ssh-keys
	@echo "Rebuilding Debian SSH server image from scratch..."
	make server-stop
	docker-compose -f $(COMPOSE_FILE) build --no-cache --pull
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "Rebuild completed. Server is running on port $(SSH_PORT)"

# Clean up everything
server-clean:
	@echo "Cleaning up SSH server resources..."
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	@echo "Cleanup completed"

# Clean SSH host key from known_hosts
server-clean-ssh-keys:
	@echo "Removing SSH host key for [localhost]:$(SSH_PORT) from known_hosts..."
	@ssh-keygen -R "[localhost]:$(SSH_PORT)" 2>/dev/null || true
	@echo "SSH host key removed. You can now connect without host key conflicts."

# Status check
server-status:
	@echo "SSH Server Status:"
	docker-compose -f $(COMPOSE_FILE) ps

# Prepare necessary files
prepare:
	@mkdir -p logs
	@touch logs/.bash_history
	@echo "Preparation completed. Logs directory and files are ready."
