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
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-setup

# As root user inside container
rails-production-setup-rails-ownership:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec --user root rails sh -c 'chown -R rails:rails /home/rails/RailsApp 2>/dev/null || true'

# Production bundle commands
rails-production-bundle:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-bundle

rails-production-bundle-reset:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-bundle-reset

# Production assets commands
rails-production-assets:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-assets-precompile

rails-production-precompile:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-precompile

rails-production-assets-clean:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-assets-clean

# Production database commands
rails-production-db-create:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-create

rails-production-db-migrate:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-migrate

rails-production-db-seed:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-seed

rails-production-db-setup:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-create
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-migrate
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-seed

rails-production-db-reset:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-reset

rails-production-db-rollback:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-rollback

# Production server commands
rails-production-server:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails bash -c "RAILS_ENV=production bundle exec puma -b tcp://0.0.0.0:3000"

rails-production-server-daemon:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec -d rails bash -c "RAILS_ENV=production bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/production-server.pid"

rails-production-start:
	make env-setup-production
	make rails-production-up
	make rails-production-setup
	make rails-production-setup-rails-ownership
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-bundle
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-create
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-db-migrate
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-assets-clean
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-assets-precompile
	make rails-production-server-daemon

rails-production-stop:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-stop

# Production console
rails-production-console:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-console

# Production logs (delegated to container)
rails-production-log-tail:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-log-tail

rails-production-logs:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-logs

rails-production-log-clear:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails make production-log-clear

# =============================================================================
# Docker Container Management Commands (host-level only)
# =============================================================================

# Start production containers in detached mode
rails-production-up:
	RAILS_ENV=production RAILS_ENV=production docker compose -f $(COMPOSE_FILE) up -d

# Stop production containers
rails-production-down:
	RAILS_ENV=production RAILS_ENV=production docker compose -f $(COMPOSE_FILE) down

# Restart production containers
rails-production-restart:
	make rails-production-down
	make rails-production-up

# View production logs from Docker
rails-production-docker-logs:
	RAILS_ENV=production RAILS_ENV=production docker compose -f $(COMPOSE_FILE) logs -f rails

# Production bash access
rails-production-bash:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) exec rails bash

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
