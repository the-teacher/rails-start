# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

include Makefiles/100_Project.mk
include Makefiles/200_Rails.mk
include Makefiles/300_Rails-Production.mk

# Main help command
help:
	@echo "Rails Start - Available commands:"
	@echo "=============================================================="
	@echo "Quick start:"
	@echo "  make start               - Start all containers"
	@echo "  make rails-start         - Start Rails development server"
	@echo "  make production-rails-start - Start Rails production server"
	@echo "=============================================================="
	@echo "Detailed help by category:"
	@echo "  make project-help       - Project management commands"
	@echo "  make rails-help         - Rails development commands"
	@echo "  make rails-production-help - Production Rails commands"
	@echo "  make base-images-help    - Base image building commands"
	@echo "  make main-images-help    - Main image building commands"
	@echo "  make common-images-help   - General images commands"
	@echo "=============================================================="