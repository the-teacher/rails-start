# Docker compose commands for Rails application
COMPOSE_FILE := ./docker/docker-compose.yml

# Install dependencies
rails-bundle:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle install"

# Create database
rails-db-create:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:create"

# Migrate database
rails-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:migrate"

# Seed database
rails-db-seed:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails db:seed"

# Show running processes inside Rails container
rails-status:
	@echo "Rails container processes:"
	@echo "=============================================================="
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "ps aux"

# Start containers
rails-start:
	make rails-bundle
	make rails-db-create
	make rails-db-migrate
	docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "bundle exec rails s -b 0.0.0.0 -p 3000"

# Help for Rails commands
help-rails:
	@echo "=============================================================="
	@echo "Rails development commands:"
	@echo "=============================================================="
	@echo "  make rails-start         - Start Rails server with all dependencies"
	@echo "  make rails-bundle        - Install Ruby dependencies"
	@echo "  make rails-db-create     - Create database"
	@echo "  make rails-db-migrate    - Run database migrations"
	@echo "  make rails-db-seed       - Seed the database"
	@echo "  make rails-status        - Show running processes inside Rails container"
	@echo "=============================================================="

