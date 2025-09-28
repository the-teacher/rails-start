# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

# Production Rails commands (to be executed inside the container)
# These commands are for running Rails in production mode locally

# Production setup
production-setup:
	make production-bundle
	make production-db-create
	make production-db-migrate
	make production-assets-precompile

# Production assets
production-assets-precompile:
	RAILS_ENV=production bundle exec rails assets:precompile

production-precompile:
	make production-assets-precompile

# Production server
production-server:
	make production-bundle
	make production-db-create
	make production-db-migrate
	make production-assets-clean
	make production-assets-precompile
	RAILS_ENV=production bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/production-server.pid > log/production-puma.log 2>&1 &

production-start:
	make production-server

# Gracefully stop the production server
production-stop:
	kill -TERM $$(cat tmp/pids/production-server.pid) && rm -f tmp/pids/production-server.pid

# Production console
production-console:
	RAILS_ENV=production bundle exec rails console

# Production logs
production-log-tail:
	tail -f -n 100 log/production.log

production-logs:
	make production-log-tail

production-log-clear:
	> log/production.log

# Production dependencies
production-bundle:
	bundle config set --local without 'development test'
	RAILS_ENV=production bundle install

# Reset bundle configuration (for switching back to development)
production-bundle-reset:
	bundle config unset --local without
	bundle install

# Production database commands
production-db-create:
	RAILS_ENV=production bundle exec rails db:create

production-db-migrate:
	RAILS_ENV=production bundle exec rails db:migrate

production-db-seed:
	RAILS_ENV=production bundle exec rails db:seed

production-db-reset:
	@echo "Resetting the production database (drop, create, migrate, seed)..."
	@echo "You have 10 seconds to cancel (Ctrl+C)..."
	@sleep 10
	RAILS_ENV=production bundle exec rails db:reset

production-db-rollback:
	RAILS_ENV=production bundle exec rails db:rollback

# Production assets cleanup
production-assets-clean:
	RAILS_ENV=production bundle exec rails assets:clobber

# Help for production Rails commands
production-help:
	@echo "=============================================================="
	@echo "Production Rails commands (run inside container):"
	@echo "=============================================================="
	@echo "Setup:"
	@echo "  make production-setup          - Setup production environment"
	@echo "  make production-bundle         - Install production dependencies"
	@echo "  make production-bundle-reset   - Reset bundle config (for dev mode)"
	@echo ""
	@echo "Database:"
	@echo "  make production-db-create      - Create production database"
	@echo "  make production-db-migrate     - Run production database migrations"
	@echo "  make production-db-seed        - Seed production database"
	@echo "  make production-db-reset       - Reset production database"
	@echo "  make production-db-rollback    - Rollback production database migration"
	@echo ""
	@echo "Server:"
	@echo "  make production-server         - Start Rails production server"
	@echo "  make production-start          - Start Rails production server"
	@echo "  make production-stop           - Stop Rails production server"
	@echo ""
	@echo "Console:"
	@echo "  make production-console        - Open Rails production console"
	@echo ""
	@echo "Assets:"
	@echo "  make production-assets-precompile - Precompile assets for production"
	@echo "  make production-precompile     - Precompile assets for production"
	@echo "  make production-assets-clean   - Clean production assets"
	@echo ""
	@echo "Logs:"
	@echo "  make production-log-tail       - Tail production log"
	@echo "  make production-logs           - Tail production log"
	@echo "  make production-log-clear      - Clear production log"
	@echo "=============================================================="
