# Suppress command output (to avoid messages like "Entering directory ...")
MAKEFLAGS += --no-print-directory

# Production Rails commands (to be executed inside the container)
# These commands are for running Rails in production mode locally

# Production setup
prod-setup:
	RAILS_ENV=production bundle install --without development test
	RAILS_ENV=production bundle exec rails db:create
	RAILS_ENV=production bundle exec rails db:migrate
	RAILS_ENV=production bundle exec rails assets:precompile

# Production assets
assets-precompile:
	RAILS_ENV=production bundle exec rails assets:precompile

precompile:
	make assets-precompile

# Production server
server-production:
	RAILS_ENV=production bundle exec rails server -b 0.0.0.0 -p 3000

prod:
	make server-production

# Production console
console-production:
	RAILS_ENV=production bundle exec rails console

# Production logs
log-tail-production:
	tail -f -n 100 log/production.log

logs-production:
	make log-tail-production

log-clear-production:
	> log/production.log

# Help for production Rails commands
rails-prod-help:
	@echo "=============================================================="
	@echo "Production Rails commands (run inside container):"
	@echo "=============================================================="
	@echo "Setup:"
	@echo "  make prod-setup          - Setup production environment"
	@echo ""
	@echo "Server:"
	@echo "  make server-production   - Start Rails production server"
	@echo "  make prod                - Start Rails production server"
	@echo ""
	@echo "Console:"
	@echo "  make console-production  - Open Rails production console"
	@echo ""
	@echo "Assets:"
	@echo "  make assets-precompile   - Precompile assets for production"
	@echo "  make precompile          - Precompile assets for production"
	@echo ""
	@echo "Logs:"
	@echo "  make log-tail-production - Tail production log"
	@echo "  make logs-production     - Tail production log"
	@echo "  make log-clear-production- Clear production log"
	@echo "=============================================================="
