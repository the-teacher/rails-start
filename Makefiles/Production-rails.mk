# Production Rails commands for Docker deployment
COMPOSE_FILE := ./docker/docker-compose.yml

# Install production dependencies
production-rails-bundle:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle install --without development test"

# Precompile assets for production
production-rails-assets:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails assets:precompile"

# Create production database
production-rails-db-create:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:create"

# Migrate production database
production-rails-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:migrate"

# Seed production database
production-rails-db-seed:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:seed"

# Setup production database (create + migrate + seed)
production-rails-db-setup:
	make production-rails-db-create
	make production-rails-db-migrate
	make production-rails-db-seed

# Start Rails server in production mode
production-rails-server:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails s -e production -b 0.0.0.0 -p 3000"

# Full production startup sequence
production-rails-start:
	make production-rails-bundle
	make production-rails-assets
	make production-rails-db-setup
	make production-rails-server

# Start production containers in detached mode
production-rails-up:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) up -d

# Stop production containers
production-rails-down:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) down

# Restart production containers
production-rails-restart:
	make production-rails-down
	make production-rails-up

# View production logs
production-rails-logs:
	RAILS_ENV=production docker compose -f $(COMPOSE_FILE) logs -f rails_app

# Clean production assets
production-rails-clean:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails assets:clobber"

# Production console
production-rails-console:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails c"

# Production bash access
production-rails-bash:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash

# Help for Production Rails commands
help-production-rails:
	@echo "=============================================================="
	@echo "Production Rails commands:"
	@echo "=============================================================="
	@echo "  make production-rails-start    - Full production startup sequence"
	@echo "  make production-rails-server   - Start Rails server in production mode"
	@echo "  make production-rails-bundle   - Install production dependencies"
	@echo "  make production-rails-assets   - Precompile assets for production"
	@echo "  make production-rails-db-setup - Setup production database"
	@echo "  make production-rails-console  - Open production Rails console"
	@echo "  make production-rails-logs     - View production logs"
	@echo "  make production-rails-up       - Start production containers in detached mode"
	@echo "  make production-rails-down     - Stop production containers"
	@echo "  make production-rails-restart  - Restart production containers"
	@echo "  make production-rails-bash     - Access bash in production RAILS_ENV"
	@echo "  make production-rails-clean    - Clean production assets"
	@echo "=============================================================="
