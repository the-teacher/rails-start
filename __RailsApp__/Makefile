include ./Makefiles/100_Rails.mk
include ./Makefiles/200_Project.mk

# Main help command for internal commands
help:
	@echo "Rails App - Internal Commands (running inside container):"
	@echo "=============================================================="
	@echo "Quick start:"
	@echo "  make setup               - Complete project setup"
	@echo "  make dev                 - Start development server"
	@echo "  make prod                - Start production server"
	@echo "=============================================================="
	@echo "Detailed help by category:"
	@echo "  make project-internal-help - Internal project management commands"
	@echo "  make rails-internal-help   - Internal Rails development commands"
	@echo "=============================================================="

# Default target
.DEFAULT_GOAL := help