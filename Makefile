include Makefiles/BaseImages.mk
include Makefiles/MainImages.mk
include Makefiles/Project.mk
include Makefiles/Rails.mk
include Makefiles/Production-rails.mk

# Main help command
help:
	@echo "15min_blog - Available commands:"
	@echo "=============================================================="
	@echo "Quick start:"
	@echo "  make start               - Start all containers"
	@echo "  make rails-start         - Start Rails development server"
	@echo "  make production-rails-start - Start Rails production server"
	@echo "=============================================================="
	@echo "Detailed help by category:"
	@echo "  make help-project        - Project management commands"
	@echo "  make help-rails          - Rails development commands"
	@echo "  make help-production-rails - Production Rails commands"
	@echo "  make help-base-image     - Base image building commands"
	@echo "  make help-main-image     - Main image building commands"
	@echo "  make help-image-build    - General image building commands"
	@echo "=============================================================="

# General help for image building commands
help-image-build:
	@echo "=============================================================="
	@echo "General image building commands:"
	@echo "=============================================================="
	@echo "  make check-images         - Check if images exist locally"
	@echo "  make image-sizes          - Show sizes of all built images"
	@echo "  make show-all-images      - Show all Docker images"
	@echo "  make clean-all-images     - Remove all project images (base and main)"
	@echo "=============================================================="


# Clean all images (base and main)
clean-all-images:
	@echo "Cleaning all project images (base and main)..."
	make clean-base-images
	make clean-main-images
	@echo "All images cleanup completed!"
