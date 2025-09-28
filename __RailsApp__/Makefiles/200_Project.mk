
# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

# Common project commands (to be executed inside the container)
# These commands work for both development and production environments

# Install dependencies (ensure all groups are included)
bundle:
	bundle config unset --local without || true
	cat /usr/local/bundle/config
	bundle install

update-bundler:
	gem install bundler
	bundle update
	bundler -v
	@echo "Ensure old versions of bundler are uninstalled to avoid conflicts."

# Database commands
db-create:
	bundle exec rails db:create

db-migrate:
	bundle exec rails db:migrate

migrate:
	make db-migrate

db-seed:
	bundle exec rails db:seed

seed:
	make db-seed

db-drop:
	@echo "Dropping the database..."
	@echo "You have 10 seconds to cancel (Ctrl+C)..."
	@sleep 10
	bundle exec rails db:drop

db-reset:
	@echo "Resetting the database (drop, create, migrate, seed)..."
	@echo "You have 10 seconds to cancel (Ctrl+C)..."
	@sleep 10
	bundle exec rails db:reset

db-rollback:
	bundle exec rails db:rollback

# Rails generators
generate:
	@echo "Usage: make generate-model name=ModelName"
	@echo "       make generate-controller name=ControllerName"
	@echo "       make generate-migration name=migration_name"

generate-model:
	bundle exec rails generate model $(name)

model:
	make generate-model name=$(name)

generate-controller:
	bundle exec rails generate controller $(name)

controller:
	make generate-controller name=$(name)

generate-migration:
	bundle exec rails generate migration $(name)

migration:
	make generate-migration name=$(name)

# Testing
test:
	bundle exec rails test

test-system:
	bundle exec rails test:system

# Assets
assets-clean:
	bundle exec rails assets:clean

# Routes
routes:
	bundle exec rails routes

# Rails tasks
tasks:
	bundle exec rails -T

# Security and code quality
brakeman:
	bundle exec brakeman

rubocop:
	bundle exec rubocop

rubocop-fix:
	bundle exec rubocop -A

# Clean up
clean:
	make assets-clean
	rm -rf log/*.log
	rm -rf tmp/cache/*

# Check environment
env-check:
	@echo "Ruby version: $(shell ruby -v)"
	@echo "Bundler version: $(shell bundle -v)"
	@echo "Rails version: $(shell bundle exec rails -v)"
	@echo "Current environment: $(RAILS_ENV)"
	@echo "Database configuration:"
	@bundle exec rails runner "puts ActiveRecord::Base.connection_db_config.configuration_hash"

# Show running processes (useful inside container)
status:
	@echo "Container processes:"
	@ps aux

# Show disk usage
disk-usage:
	@echo "Disk usage:"
	@df -h
	@echo ""
	@echo "Directory sizes:"
	@du -sh * | sort -hr

# Network info (useful for debugging)
network:
	@echo "Network interfaces:"
	@ip addr show 2>/dev/null || ifconfig
	@echo ""
	@echo "Listening ports:"
	@netstat -tlnp 2>/dev/null || ss -tlnp

# Alias for project-help
project-internal-help:
	make project-help

# Help for common project commands
project-help:
	@echo "=============================================================="
	@echo "Common Project commands (run inside container):"
	@echo "=============================================================="
	@echo "Dependencies:"
	@echo "  make bundle              - Install Ruby dependencies"
	@echo "  make update-bundler      - Update bundler and dependencies"
	@echo ""
	@echo "Database:"
	@echo "  make db-create           - Create database"
	@echo "  make db-migrate          - Run database migrations"
	@echo "  make migrate             - Run database migrations (alias)"
	@echo "  make db-seed             - Seed the database"
	@echo "  make seed                - Seed the database (alias)"
	@echo "  make db-drop             - Drop database"
	@echo "  make db-reset            - Reset database (drop, create, migrate, seed)"
	@echo "  make db-rollback         - Rollback last migration"
	@echo ""
	@echo "Generators:"
	@echo "  make generate-model name=User       - Generate model"
	@echo "  make model name=User                - Generate model (alias)"
	@echo "  make generate-controller name=Users - Generate controller"
	@echo "  make controller name=Users          - Generate controller (alias)"
	@echo "  make generate-migration name=add_email_to_users - Generate migration"
	@echo "  make migration name=add_email_to_users - Generate migration (alias)"
	@echo "  make generate                       - Show generator usage"
	@echo ""
	@echo "Testing:"
	@echo "  make test                - Run all tests"
	@echo "  make test-system         - Run system tests"
	@echo ""
	@echo "Assets:"
	@echo "  make assets-clean        - Clean compiled assets"
	@echo ""
	@echo "Utilities:"
	@echo "  make routes              - Show all routes"
	@echo "  make tasks               - Show all available Rails tasks"
	@echo ""
	@echo "Code Quality:"
	@echo "  make brakeman            - Run security analysis"
	@echo "  make rubocop             - Run code style analysis"
	@echo "  make rubocop-fix         - Auto-fix code style issues"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean               - Clean assets, logs, cache"
	@echo ""
	@echo "Information:"
	@echo "  make env-check           - Check environment versions and configuration"
	@echo "  make status              - Show running processes"
	@echo "  make disk-usage          - Show disk usage information"
	@echo "  make network             - Show network configuration"
	@echo "=============================================================="
