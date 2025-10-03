# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# Docker compose commands for Rails application
COMPOSE_FILE := ./docker/docker-compose.yml

# Start containers
start:
	make project-setup-structure
	make env-setup-development
	docker compose -f $(COMPOSE_FILE) up -d

# Start containers
up:
	make start

# Stop containers
stop:
	docker compose -f $(COMPOSE_FILE) down

# Stop containers
down:
	make stop

# Show running containers status
status:
	@echo "Running containers:"
	@docker compose -f $(COMPOSE_FILE) ps --format "table {{.Name}}\t{{.Image}}\t{{.Service}}\t{{.Status}}\t{{.Ports}}"

# Build or rebuild containers
build:
	docker compose -f $(COMPOSE_FILE) build

# Rebuild containers
rebuild:
	docker compose -f $(COMPOSE_FILE) build --no-cache

# Open shell in rails_app container as root user
root-shell:
	docker compose -f $(COMPOSE_FILE) exec --user root rails_app bash

# Open shell in rails_app container
shell:
	docker compose -f $(COMPOSE_FILE) exec rails_app bash

project-setup-structure:
	mkdir -p __RailsApp__/tmp
	touch __RailsApp__/tmp/.bash_history
	touch __RailsApp__/tmp/.irb_history
	make project-setup-irb-config
	
project-setup-irb-config:
	touch __RailsApp__/tmp/.irbrc
	@echo "" > __RailsApp__/tmp/.irbrc
	@echo "# IRB Configuration" >> __RailsApp__/tmp/.irbrc
	@echo "# See ENV: IRBRC" >> __RailsApp__/tmp/.irbrc
	@echo "IRB.conf[:HISTORY_FILE] = '/home/rails/app/tmp/.irb_history'" >> __RailsApp__/tmp/.irbrc
	@echo "IRB.conf[:SAVE_HISTORY] = 1000" >> __RailsApp__/tmp/.irbrc
	@echo "IRB.conf[:AUTO_INDENT] = true" >> __RailsApp__/tmp/.irbrc

reset:
	rm -rf  ENV/local/.env.*

# Help for Project management commands
project-help:
	@echo "=============================================================="
	@echo "Project management commands:"
	@echo "=============================================================="
	@echo "  make start               - Start all containers"
	@echo "  make up                  - Alias for start"
	@echo "  make stop                - Stop all containers"
	@echo "  make down                - Alias for stop"
	@echo "  make status              - Show running containers status"
	@echo "  make build               - Build or rebuild containers"
	@echo "  make rebuild             - Rebuild containers"
	@echo "  make shell               - Open shell in rails_app container"
	@echo "=============================================================="
