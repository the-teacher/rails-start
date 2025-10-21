# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

include ./Makefiles/100_Project.mk
include ./Makefiles/200_Rails.mk
include ./Makefiles/300_Production.mk
include ./Makefiles/400_Test_Server.mk

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