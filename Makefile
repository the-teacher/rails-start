include Makefiles/100_Base-Images.mk
include Makefiles/200_Main-Images.mk
include Makefiles/300_Common.mk
include Makefiles/400_Project.mk
include Makefiles/500_Rails.mk
include Makefiles/600_Production-Rails.mk

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
	@echo "  make help-project        - Project management commands"
	@echo "  make help-rails          - Rails development commands"
	@echo "  make help-production-rails - Production Rails commands"
	@echo "  make base-images-help    - Base image building commands"
	@echo "  make main-images-help    - Main image building commands"
	@echo "  make common-help  		  - General commands"
	@echo "=============================================================="