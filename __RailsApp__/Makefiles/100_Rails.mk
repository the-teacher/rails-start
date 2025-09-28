# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

# Development Rails commands (to be executed inside the container)
# These commands assume they are running inside the Rails container environment

# Development setup
dev-setup:
	make bundle
	make db-create
	make db-migrate
	make db-seed

# Rails development server
server:
	bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/server.pid > log/puma.log 2>&1 &

dev:
	make server

start:
	make server

rails-start:
	make server

# Gracefully stop the development server
stop:
	kill -TERM $$(cat tmp/pids/server.pid) && rm -f tmp/pids/server.pid

# Development Rails console
console:
	bundle exec rails console

# Development logs
log-tail:
	tail -f -n 100 log/development.log

logs:
	make log-tail

log-clear:
	> log/development.log

# Help for development Rails commands
rails-dev-help:
	@echo "=============================================================="
	@echo "Development Rails commands (run inside container):"
	@echo "=============================================================="
	@echo "Setup:"
	@echo "  make dev-setup           - Setup development environment"
	@echo ""
	@echo "Server:"
	@echo "  make server              - Start Rails development server"
	@echo "  make dev                 - Start Rails development server"
	@echo "  make start               - Start Rails development server"
	@echo "  make stop                - Stop Rails development server"
	@echo ""
	@echo "Console:"
	@echo "  make console             - Open Rails development console"
	@echo ""
	@echo "Logs:"
	@echo "  make log-tail            - Tail development log"
	@echo "  make logs                - Tail development log"
	@echo "  make log-clear           - Clear development log"
	@echo "=============================================================="
