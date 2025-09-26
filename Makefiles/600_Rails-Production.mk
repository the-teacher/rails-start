# Production Rails commands for Docker deployment
COMPOSE_FILE := ./docker/docker-compose.yml

# Install production dependencies
rails-production-bundle:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle install --without development test"

# Precompile assets for production
rails-production-assets:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails assets:precompile"

# Create production database
rails-production-db-create:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:create"

# Migrate production database
rails-production-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:migrate"

# Seed production database
rails-production-db-seed:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:seed"

# Setup production database (create + migrate + seed)
rails-production-db-setup:
	make rails-production-db-create
	make rails-production-db-migrate
	make rails-production-db-seed

# Start Rails server in production mode
rails-production-server:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails s -e production -b 0.0.0.0 -p 3000"

# Full production startup sequence
rails-production-start:
	make rails-production-bundle
	make rails-production-assets
	make rails-production-db-setup
	make rails-production-server

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

# View production logs
rails-production-logs:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) logs -f rails_app

# Clean production assets
rails-production-clean:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails assets:clobber"

# Production console
rails-production-console:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails c"

# Production bash access
rails-production-bash:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash

# Help for Production Rails commands
help-rails-production:
	@echo "=============================================================="
	@echo "Production Rails commands:"
	@echo "=============================================================="
	@echo "  make rails-production-start    - Full production startup sequence"
	@echo "  make rails-production-server   - Start Rails server in production mode"
	@echo "  make rails-production-bundle   - Install production dependencies"
	@echo "  make rails-production-assets   - Precompile assets for production"
	@echo "  make rails-production-db-setup - Setup production database"
	@echo "  make rails-production-console  - Open production Rails console"
	@echo "  make rails-production-logs     - View production logs"
	@echo "  make rails-production-up       - Start production containers in detached mode"
	@echo "  make rails-production-down     - Stop production containers"
	@echo "  make rails-production-restart  - Restart production containers"
	@echo "  make rails-production-bash     - Access bash in production RAILS_ENV"
	@echo "  make rails-production-clean    - Clean production assets"
	@echo "=============================================================="
