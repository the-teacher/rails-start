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

# Development Rails commands (to be executed inside the container)
# These commands assume they are running inside the Rails container environment

# Application setup
setup:
	make bundle
	make db-create
	make db-migrate
	make db-seed

# Rails server
server:
	make bundle
	make db-create
	make db-migrate
	bundle exec puma -b tcp://0.0.0.0:3000 --pidfile tmp/pids/server.pid > log/puma.log 2>&1 &

start:
	make server

rails-start:
	make server

# Gracefully stop the development server
stop:
	kill -TERM $$(cat tmp/pids/server.pid) && rm -f tmp/pids/server.pid

# Rails console
console:
	bundle exec rails console

# Application logs
log-tail:
	tail -f -n 100 log/development.log

logs:
	make log-tail

log-clear:
	> log/development.log

# Alias for rails-help
rails-internal-help:
	make rails-help

# Help for Rails commands
rails-help:
	@echo "=============================================================="
	@echo "Rails commands (run inside container):"
	@echo "=============================================================="
	@echo "Setup:"
	@echo "  make setup               - Setup application environment"
	@echo ""
	@echo "Server:"
	@echo "  make server              - Start Rails server"
	@echo "  make start               - Start Rails server"
	@echo "  make rails-start         - Start Rails server"
	@echo "  make stop                - Stop Rails server"
	@echo ""
	@echo "Console:"
	@echo "  make console             - Open Rails console"
	@echo ""
	@echo "Logs:"
	@echo "  make log-tail            - Tail application log"
	@echo "  make logs                - Tail application log"
	@echo "  make log-clear           - Clear application log"
	@echo "=============================================================="
