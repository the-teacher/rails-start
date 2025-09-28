# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# Development Rails commands for Docker deployment
# These commands delegate to the container-level commands from __RailsApp__/Makefiles/200_Rails.mk
# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

COMPOSE_FILE := ./docker/docker-compose.yml

# =============================================================================
# Delegated Development Commands (using __RailsApp__/Makefiles/200_Rails.mk inside container)
# =============================================================================

# Development setup
rails-setup:
	docker compose -f $(COMPOSE_FILE) exec rails_app make setup

# Development bundle commands
rails-bundle:
	docker compose -f $(COMPOSE_FILE) exec rails_app make bundle

# Development database commands
rails-db-create:
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-create

rails-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-migrate

rails-db-seed:
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-seed

# Development server commands
rails-server:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec puma -b tcp://0.0.0.0:3000"

rails-server-daemon:
	docker compose -f $(COMPOSE_FILE) exec -d rails_app bash -c "bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/server.pid"

rails-start:
	make up
	docker compose -f $(COMPOSE_FILE) exec rails_app make bundle
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-create
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-migrate
	make rails-server-daemon

rails-stop:
	docker compose -f $(COMPOSE_FILE) exec rails_app make stop

# Development console
rails-console:
	docker compose -f $(COMPOSE_FILE) exec rails_app make console

# Development logs (delegated to container)
rails-log-tail:
	docker compose -f $(COMPOSE_FILE) exec rails_app make log-tail

rails-logs:
	docker compose -f $(COMPOSE_FILE) exec rails_app make logs

rails-log-clear:
	docker compose -f $(COMPOSE_FILE) exec rails_app make log-clear

# Show running processes inside Rails container
rails-status:
	@echo "Rails container processes:"
	@echo "=============================================================="
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "ps aux"

# =============================================================================
# Docker Container Management Commands (host-level only)
# =============================================================================

# Development bash access
rails-bash:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash

# Help for Rails commands
rails-help:
	@echo "=================================================================="
	@echo "Development Rails commands (Docker host-level, delegates to __RailsApp__/Makefiles/200_Rails.mk):"
	@echo "=================================================================="
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make rails-setup             - Full development setup (delegated)"
	@echo "  make rails-bundle            - Install development dependencies"
	@echo ""
	@echo "Database:"
	@echo "  make rails-db-create         - Create development database"
	@echo "  make rails-db-migrate        - Run development database migrations"
	@echo "  make rails-db-seed           - Seed development database"
	@echo ""
	@echo "Server:"
	@echo "  make rails-server            - Start Rails server (interactive mode)" 
	@echo "  make rails-server-daemon     - Start Rails server (daemon mode)"
	@echo "  make rails-start             - Full setup + start server in daemon mode"
	@echo "  make rails-stop              - Stop Rails development server"
	@echo ""
	@echo "Console & Logs:"
	@echo "  make rails-console           - Open development Rails console"
	@echo "  make rails-log-tail          - Tail development application log"
	@echo "  make rails-logs              - Tail development application log (alias)"
	@echo "  make rails-log-clear         - Clear development application log"
	@echo ""
	@echo "Docker Container Management:"
	@echo "  make rails-bash              - Access bash in development container"
	@echo "  make rails-status            - Show running processes inside Rails container"
	@echo ""
	@echo "Note: Most commands delegate to __RailsApp__/Makefiles/200_Rails.mk inside the container."
	@echo "=================================================================="

