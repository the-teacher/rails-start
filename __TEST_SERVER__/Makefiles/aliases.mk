# Short command aliases for convenience

# Help for aliases
help-aliases:
	@echo "=== Short Command Aliases ==="
	@echo "  make start           - Alias for server-start"
	@echo "  make stop            - Alias for server-stop"
	@echo "  make restart         - Alias for server-restart"
	@echo "  make down            - Alias for server-stop"
	@echo "  make status          - Alias for server-status"
	@echo "  make shell           - Alias for server-shell"
	@echo "  make ssh             - Alias for server-ssh"
	@echo "  make build           - Alias for server-build"
	@echo "  make rebuild         - Alias for server-rebuild"
	@echo "  make clean           - Alias for server-clean"
	@echo ""

# Start the server
start:
	make server-start

# Stop the server
down:
	make server-stop

# Stop the server
stop:
	make server-stop

restart:
	make server-restart

# Show server status
status:
	make server-status

# Get shell access
shell:
	make server-shell

# Connect via SSH (using keys)
ssh:
	make server-ssh

# Build server image
build:
	make server-build

# Rebuild server image
rebuild:
	make server-rebuild

# Clean server resources
clean:
	make server-clean
