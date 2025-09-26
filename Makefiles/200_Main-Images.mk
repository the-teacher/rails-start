# ===============================================================
# Main image (using base image)
# ===============================================================
MAIN_DOCKERFILE = docker/_Main.Dockerfile
MAIN_IMAGE_NAME = iamteacher/rails-start.main

# Build main image for ARM64
main-image-arm64-build:
	docker build \
		-t $(MAIN_IMAGE_NAME):arm64 \
		-f $(MAIN_DOCKERFILE) \
		--platform linux/arm64 \
		.

# Build main image for AMD64
main-image-amd64-build:
	docker build \
		-t $(MAIN_IMAGE_NAME):amd64 \
		-f $(MAIN_DOCKERFILE) \
		--platform linux/amd64 \
		.

# Build main images for all platforms
main-images-build:
	make main-image-arm64-build
	make main-image-amd64-build

# Create manifest for main image
main-images-manifest-create:
	docker manifest create \
		$(MAIN_IMAGE_NAME):latest \
		--amend $(MAIN_IMAGE_NAME):arm64 \
		--amend $(MAIN_IMAGE_NAME):amd64

# Push main images to Docker Hub
main-images-push:
	docker push $(MAIN_IMAGE_NAME):arm64
	docker push $(MAIN_IMAGE_NAME):amd64

# Push main image manifest to Docker Hub
main-images-manifest-push:
	make main-images-push
	docker manifest push --purge $(MAIN_IMAGE_NAME):latest

# Complete workflow for building and publishing main images
main-images-update:
	make main-images-build
	make main-images-push
	make main-images-manifest-create
	make main-images-manifest-push
	@echo "Main images built and published successfully!"

# Run shell in ARM64 main image
main-image-arm64-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		$(MAIN_IMAGE_NAME):arm64 \
		/bin/bash

# Run shell in AMD64 main image
main-image-amd64-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		$(MAIN_IMAGE_NAME):amd64 \
		/bin/bash

# Enter shell of the latest ARM64 main image as root user
main-image-arm64-root-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		--user root \
		$(MAIN_IMAGE_NAME):arm64 \
		/bin/bash

# Enter shell of the latest AMD64 main image as root user
main-image-amd64-root-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		--user root \
		$(MAIN_IMAGE_NAME):amd64 \
		/bin/bash

# Run Rails app in container on ARM64
main-image-arm64-rails-run:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		-p 3000:3000 \
		$(MAIN_IMAGE_NAME):arm64 \
		bash -c "cd /app && bundle install && rails server -b 0.0.0.0"

# Run Rails app in container on AMD64
main-image-amd64-rails-run:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		-p 3000:3000 \
		$(MAIN_IMAGE_NAME):amd64 \
		bash -c "cd /app && bundle install && rails server -b 0.0.0.0"

# Clean main docker images related to this project
main-images-clean:
	@echo "Cleaning main images..."
	@echo "Removing tagged images..."
	-docker rmi $(MAIN_IMAGE_NAME):arm64 $(MAIN_IMAGE_NAME):amd64 $(MAIN_IMAGE_NAME):latest
	@echo "Main images cleanup completed!" 

# Help for main image building commands
main-images-help:
	@echo "=============================================================="
	@echo "Main image building commands:"
	@echo "=============================================================="
	@echo "Single architecture commands (main-image-*):"
	@echo "  make main-image-arm64-build         - Build main image for ARM64"
	@echo "  make main-image-amd64-build         - Build main image for AMD64"
	@echo "  make main-image-arm64-shell         - Enter shell of main ARM64 image"
	@echo "  make main-image-amd64-shell         - Enter shell of main AMD64 image"
	@echo "  make main-image-arm64-root-shell    - Enter shell of main ARM64 image as root user"
	@echo "  make main-image-amd64-root-shell    - Enter shell of main AMD64 image as root user"
	@echo "  make main-image-arm64-rails-run     - Run Rails app in ARM64 container"
	@echo "  make main-image-amd64-rails-run     - Run Rails app in AMD64 container"
	@echo ""
	@echo "Multi-architecture commands (main-images-*):"
	@echo "  make main-images-build              - Build main image for all platforms"
	@echo "  make main-images-manifest-create    - Create manifest for main image"
	@echo "  make main-images-push               - Push main images to Docker Hub"
	@echo "  make main-images-manifest-push      - Push manifest to Docker Hub"
	@echo "  make main-images-clean              - Remove all main project images"
	@echo ""
	@echo "Complete workflow:"
	@echo "  make main-images-update             - Build, push images and manifest"
	@echo "=============================================================="