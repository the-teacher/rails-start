# ===============================================================
# Main image (using base image)
# ===============================================================
MAIN_DOCKERFILE = docker/Dockerfile
MAIN_IMAGE_NAME = iamteacher/blog_15min

# Build main image for ARM64
build-main-arm64:
	docker build \
		-t $(MAIN_IMAGE_NAME):arm64 \
		-f $(MAIN_DOCKERFILE) \
		--platform linux/arm64 \
		.

# Build main image for AMD64
build-main-amd64:
	docker build \
		-t $(MAIN_IMAGE_NAME):amd64 \
		-f $(MAIN_DOCKERFILE) \
		--platform linux/amd64 \
		.

# Build main images for all platforms
build-main-all:
	make build-main-arm64
	make build-main-amd64

# Create manifest for main image
create-main-manifest:
	docker manifest create \
		$(MAIN_IMAGE_NAME):latest \
		--amend $(MAIN_IMAGE_NAME):arm64 \
		--amend $(MAIN_IMAGE_NAME):amd64

# Push main images to Docker Hub
push-main-images:
	docker push $(MAIN_IMAGE_NAME):arm64
	docker push $(MAIN_IMAGE_NAME):amd64

# Push main image manifest to Docker Hub
push-main-manifest:
	make push-main-images
	docker manifest push --purge $(MAIN_IMAGE_NAME):latest

# Complete workflow for building and publishing main images
update-main-images:
	make build-main-all
	make push-main-images
	make create-main-manifest
	make push-main-manifest
	@echo "Main images built and published successfully!"

# Run shell in ARM64 main image
shell-main-arm64:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		$(MAIN_IMAGE_NAME):arm64 \
		/bin/bash

# Run shell in AMD64 main image
shell-main-amd64:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		$(MAIN_IMAGE_NAME):amd64 \
		/bin/bash

# Run Rails app in container on ARM64
run-rails-app-arm64:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		-p 3000:3000 \
		$(MAIN_IMAGE_NAME):arm64 \
		bash -c "cd /app && bundle install && rails server -b 0.0.0.0"

# Run Rails app in container on AMD64
run-rails-app-amd64:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		-p 3000:3000 \
		$(MAIN_IMAGE_NAME):amd64 \
		bash -c "cd /app && bundle install && rails server -b 0.0.0.0"

# Clean main docker images related to this project
clean-main-images:
	@echo "Cleaning main images..."
	@echo "Removing tagged images..."
	-docker rmi $(MAIN_IMAGE_NAME):arm64 $(MAIN_IMAGE_NAME):amd64 $(MAIN_IMAGE_NAME):latest
	@echo "Main images cleanup completed!" 

# Help for main image building commands
help-main-image:
	@echo "=============================================================="
	@echo "Main image building commands:"
	@echo "=============================================================="
	@echo "  make build-main-arm64     - Build main image for ARM64"
	@echo "  make build-main-amd64     - Build main image for AMD64"
	@echo "  make build-main-all       - Build main image for all platforms"
	@echo "  make create-main-manifest - Create manifest for main image"
	@echo "  make push-main-images     - Push main images to Docker Hub"
	@echo "  make push-main-manifest   - Push manifest to Docker Hub"
	@echo "  make update-main-images   - Build, push images and manifest"
	@echo "  make shell-main-arm64     - Enter shell of main ARM64 image"
	@echo "  make shell-main-amd64     - Enter shell of main AMD64 image"
	@echo "  make run-rails-app-arm64  - Run Rails app in ARM64 container"
	@echo "  make run-rails-app-amd64  - Run Rails app in AMD64 container"
	@echo "  make clean-main-images    - Remove all main project images"
	@echo "=============================================================="