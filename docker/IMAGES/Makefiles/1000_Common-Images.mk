# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# ===============================================================
# Common commands and variables
# ===============================================================

# Image names
BASE_IMAGE_NAME = iamteacher/rails-start.base
MAIN_IMAGE_NAME = iamteacher/rails-start.main
MEDIA_IMAGE_NAME = iamteacher/rails-start.media

# ===============================================================
# Image building commands
# ===============================================================

# General help for common commands
common-images-help:
	@echo "=============================================================="
	@echo "General commands:"
	@echo "=============================================================="
	@echo "  make common-images-base-check    - Check if base images exist locally"
	@echo "  make common-images-main-check    - Check if main images exist locally"
	@echo "  make common-images-media-check   - Check if media images exist locally"
	@echo "  make common-images-check-all     - Check if all images exist locally"
	@echo "  make common-images-base-sizes    - Show sizes of base images"
	@echo "  make common-images-main-sizes    - Show sizes of main images"
	@echo "  make common-images-media-sizes   - Show sizes of media images"
	@echo "  make common-images-sizes-all     - Show sizes of all images"
	@echo "  make common-images-show-all      - Show all Docker images"
	@echo "  make common-images-clean         - Remove all project images (base, main, media)"
	@echo ""
	@echo "Shortcuts:"
	@echo "  make images-check                - Alias for common-images-check-all"
	@echo "  make images-sizes                - Alias for common-images-sizes-all"
	@echo "=============================================================="

# Check if base images exist locally
common-images-base-check:
	@echo "Checking if base images exist locally..."
	@docker image inspect $(BASE_IMAGE_NAME):arm64 >/dev/null 2>&1 || (echo "Error: Image $(BASE_IMAGE_NAME):arm64 not found. Run 'make base-image-arm64-build' first." && exit 1)
	@docker image inspect $(BASE_IMAGE_NAME):amd64 >/dev/null 2>&1 || (echo "Error: Image $(BASE_IMAGE_NAME):amd64 not found. Run 'make base-image-amd64-build' first." && exit 1)
	@echo "All required base images exist."
	@echo "Image $(BASE_IMAGE_NAME):arm64:"
	@docker image inspect $(BASE_IMAGE_NAME):arm64 | grep -E '"Id":|"RepoTags":'
	@echo "Image $(BASE_IMAGE_NAME):amd64:"
	@docker image inspect $(BASE_IMAGE_NAME):amd64 | grep -E '"Id":|"RepoTags":'

# Check if main images exist locally
common-images-main-check:
	@echo "Checking if main images exist locally..."
	@docker image inspect $(MAIN_IMAGE_NAME):arm64 >/dev/null 2>&1 || (echo "Error: Image $(MAIN_IMAGE_NAME):arm64 not found. Run 'make main-image-arm64-build' first." && exit 1)
	@docker image inspect $(MAIN_IMAGE_NAME):amd64 >/dev/null 2>&1 || (echo "Error: Image $(MAIN_IMAGE_NAME):amd64 not found. Run 'make main-image-amd64-build' first." && exit 1)
	@echo "All required main images exist."
	@echo "Image $(MAIN_IMAGE_NAME):arm64:"
	@docker image inspect $(MAIN_IMAGE_NAME):arm64 | grep -E '"Id":|"RepoTags":'
	@echo "Image $(MAIN_IMAGE_NAME):amd64:"
	@docker image inspect $(MAIN_IMAGE_NAME):amd64 | grep -E '"Id":|"RepoTags":'

# Check if media images exist locally
common-images-media-check:
	@echo "Checking if media images exist locally..."
	@docker image inspect $(MEDIA_IMAGE_NAME):arm64 >/dev/null 2>&1 || (echo "Error: Image $(MEDIA_IMAGE_NAME):arm64 not found. Run 'make media-image-arm64-build' first." && exit 1)
	@docker image inspect $(MEDIA_IMAGE_NAME):amd64 >/dev/null 2>&1 || (echo "Error: Image $(MEDIA_IMAGE_NAME):amd64 not found. Run 'make media-image-amd64-build' first." && exit 1)
	@echo "All required media images exist."
	@echo "Image $(MEDIA_IMAGE_NAME):arm64:"
	@docker image inspect $(MEDIA_IMAGE_NAME):arm64 | grep -E '"Id":|"RepoTags":'
	@echo "Image $(MEDIA_IMAGE_NAME):amd64:"
	@docker image inspect $(MEDIA_IMAGE_NAME):amd64 | grep -E '"Id":|"RepoTags":'

# Check if all images exist locally
common-images-check-all:
	@echo "Checking if all images exist locally..."
	make common-images-base-check
	make common-images-main-check
	make common-images-media-check
	@echo "All project images exist."

# Show base image sizes
common-images-base-sizes:
	@echo "Checking base image sizes..."
	@echo "=============================================================="
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "$(BASE_IMAGE_NAME):(arm64|amd64)"
	@echo "=============================================================="

# Show main image sizes
common-images-main-sizes:
	@echo "Checking main image sizes..."
	@echo "=============================================================="
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "$(MAIN_IMAGE_NAME):(arm64|amd64)"
	@echo "=============================================================="

# Show media image sizes
common-images-media-sizes:
	@echo "Checking media image sizes..."
	@echo "=============================================================="
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "$(MEDIA_IMAGE_NAME):(arm64|amd64)"
	@echo "=============================================================="

# Show all project image sizes
common-images-sizes-all:
	@echo "Checking all project image sizes..."
	@echo "=============================================================="
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "($(BASE_IMAGE_NAME)|$(MAIN_IMAGE_NAME)|$(MEDIA_IMAGE_NAME)):(arm64|amd64)"
	@echo "=============================================================="

# Alias for checking all images
images-sizes:
	make common-images-sizes-all

# Alias for checking all images
images-check:
	make common-images-check-all

# Show all docker images
common-images-show-all:
	@echo "All Docker images:"
	@echo "=============================================================="
	@docker images
	@echo "=============================================================="

# Clean all images (base, main, and media)
common-images-clean:
	@echo "Cleaning all project images (base, main, and media)..."
	make base-images-clean
	make main-images-clean
	make media-images-clean
	@echo "All images cleanup completed!"

images-clean:
	make common-images-clean

# ===============================================================
# Other common commands can be added here
# ===============================================================
