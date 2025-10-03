# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# Production Rails commands for Docker deployment
# These commands delegate to the container-level commands from 300_Production.mk
# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

COMPOSE_FILE := ./docker/docker-compose.yml

# =============================================================================
# Delegated Production Commands (using 300_Production.mk inside container)
# =============================================================================

# Production setup
rails-production-setup:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-setup

# Production bundle commands
rails-production-bundle:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-bundle

rails-production-bundle-reset:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-bundle-reset

# Production assets commands
rails-production-assets:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-assets-precompile

rails-production-precompile:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-precompile

rails-production-assets-clean:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-assets-clean

# Production database commands
rails-production-db-create:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-create

rails-production-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-migrate

rails-production-db-seed:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-seed

rails-production-db-setup:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-create
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-migrate
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-seed

rails-production-db-reset:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-reset

rails-production-db-rollback:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-rollback

# Production server commands
rails-production-server:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "RAILS_ENV=production bundle exec puma -b tcp://0.0.0.0:3000"

rails-production-server-daemon:
	docker compose -f $(COMPOSE_FILE) exec -d rails_app bash -c "RAILS_ENV=production bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/production-server.pid"

rails-production-start:
	make env-setup-production
	make rails-production-up
	make rails-production-setup
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-bundle
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-create
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-db-migrate
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-assets-clean
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-assets-precompile
	make rails-production-server-daemon

rails-production-stop:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-stop

# Production console
rails-production-console:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-console

# Production logs (delegated to container)
rails-production-log-tail:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-log-tail

rails-production-logs:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-logs

rails-production-log-clear:
	docker compose -f $(COMPOSE_FILE) exec rails_app make production-log-clear

# =============================================================================
# Docker Container Management Commands (host-level only)
# =============================================================================

# Start production containers in detached mode
rails-production-up:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) up -d

# Stop production containers
rails-production-down:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) down

# Restart production containers
rails-production-restart:
	make rails-production-down
	make rails-production-up

# View production logs from Docker
rails-production-docker-logs:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) logs -f rails_app

# Production bash access
rails-production-bash:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash

# =============================================================================
# Combined Workflows 
# =============================================================================

# Full production startup sequence (delegated)
rails-production-full-start:
	make env-setup-production
	make rails-production-up
	sleep 5
	make rails-production-setup
	make rails-production-start

# Help for Production Rails commands
rails-production-help:
	@echo "=================================================================="
	@echo "Production Rails commands (Docker host-level, delegates to 300_Production.mk):"
	@echo "=================================================================="
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make rails-production-setup          - Full production setup (delegated)"
	@echo "  make rails-production-bundle         - Install production dependencies"
	@echo "  make rails-production-bundle-reset   - Reset bundle config for development"
	@echo ""
	@echo "Database:"
	@echo "  make rails-production-db-create      - Create production database"
	@echo "  make rails-production-db-migrate     - Run production database migrations"
	@echo "  make rails-production-db-seed        - Seed production database"
	@echo "  make rails-production-db-setup       - Setup production database (create+migrate+seed)"
	@echo "  make rails-production-db-reset       - Reset production database (with confirmation)"
	@echo "  make rails-production-db-rollback    - Rollback production database migration"
	@echo ""
	@echo "Assets:"
	@echo "  make rails-production-assets         - Precompile assets for production"
	@echo "  make rails-production-precompile     - Precompile assets (alias)"
	@echo "  make rails-production-assets-clean   - Clean production assets"
	@echo ""
	@echo "Server:"
	@echo "  make rails-production-server         - Start Rails server (interactive mode)"
	@echo "  make rails-production-server-daemon  - Start Rails server (daemon mode)"
	@echo "  make rails-production-start          - Full setup + start server in daemon mode"
	@echo "  make rails-production-stop           - Stop Rails production server"
	@echo ""
	@echo "Console & Logs:"
	@echo "  make rails-production-console        - Open production Rails console"
	@echo "  make rails-production-log-tail       - Tail production application log"
	@echo "  make rails-production-logs           - Tail production application log (alias)"
	@echo "  make rails-production-log-clear      - Clear production application log"
	@echo ""
	@echo "Docker Container Management:"
	@echo "  make rails-production-up             - Start production containers (detached)"
	@echo "  make rails-production-down           - Stop production containers"
	@echo "  make rails-production-restart        - Restart production containers"
	@echo "  make rails-production-docker-logs    - View Docker container logs"
	@echo "  make rails-production-bash           - Access bash in production container"
	@echo ""
	@echo "Combined Workflows:"
	@echo "  make rails-production-full-start     - Complete startup (containers + setup + server)"
	@echo ""
	@echo "Note: Most commands delegate to 300_Production.mk inside the container."
	@echo "=================================================================="
