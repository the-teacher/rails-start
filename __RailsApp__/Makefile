include ./Makefiles/100_Rails.mk
include ./Makefiles/200_Project.mk
include ./Makefiles/300_Production.mk

# Main help command for internal commands
help:
	@echo "Rails App - Internal Commands (running inside container):"
	@echo "=============================================================="
	@echo "Quick start:"
	@echo "  make start               - Start Rails server"
	@echo "  make production-start    - Start production server"
	@echo "=============================================================="
	@echo "Detailed help by category:"
	@echo "  make project-help        - Internal project management commands"
	@echo "  make rails-help          - Internal Rails commands"
	@echo "  make production-help     - Internal production commands"
	@echo "=============================================================="

# Default target
.DEFAULT_GOAL := help