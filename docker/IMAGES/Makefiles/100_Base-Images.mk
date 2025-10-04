# ===============================================================
# https://hub.docker.com/r/iamteacher/rails-start.base/tags
# ===============================================================
# Variables for building images
BASE_DOCKERFILE = ./_Base.Dockerfile
IMAGE_NAME = iamteacher/rails-start.base

# Ruby version and OS version for the base image
# https://hub.docker.com/_/ruby/tags?name=bookworm
RUBY_VERSION = 3.4.6-bookworm

# Build image for ARM64
base-image-arm64-build:
	docker build \
		-t $(IMAGE_NAME):arm64 \
		-f $(BASE_DOCKERFILE) \
		--build-arg BUILDPLATFORM="linux/arm64" \
		--build-arg TARGETARCH="arm64" \
		--build-arg RUBY_VERSION="$(RUBY_VERSION)" \
		.

# Build image for AMD64
base-image-amd64-build:
	docker build \
		-t $(IMAGE_NAME):amd64 \
		-f $(BASE_DOCKERFILE) \
		--build-arg BUILDPLATFORM="linux/amd64" \
		--build-arg TARGETARCH="amd64" \
		--build-arg RUBY_VERSION="$(RUBY_VERSION)" \
		.

# Build images for all platforms
base-images-build:
	make base-image-arm64-build
	make base-image-amd64-build

# Create manifest (local only)
base-images-manifest-create:
	docker manifest create \
		$(IMAGE_NAME):latest \
		--amend $(IMAGE_NAME):arm64 \
		--amend $(IMAGE_NAME):amd64

# Push images to Docker Hub
base-images-push:
	docker push $(IMAGE_NAME):arm64
	docker push $(IMAGE_NAME):amd64

# Push manifest to Docker Hub
base-images-manifest-push:
	make base-images-push
	docker manifest push --purge $(IMAGE_NAME):latest

# Complete workflow: build, push images, create manifest, and push manifest
base-images-update:
	make base-images-build
	make base-images-push
	make base-images-manifest-create
	make base-images-manifest-push
	@echo "All images built and pushed successfully!"

# Enter shell of the latest ARM64 image as rails user
base-image-arm64-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		$(IMAGE_NAME):arm64 \
		/bin/bash

# Enter shell of the latest AMD64 image as rails user
base-image-amd64-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		$(IMAGE_NAME):amd64 \
		/bin/bash

# Enter shell of the latest ARM64 image as root user
base-image-arm64-root-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD)/docker/checks/image_processors.sh:/root/image_processors.sh \
		--user root \
		$(IMAGE_NAME):arm64 \
		/bin/bash

# Enter shell of the latest AMD64 image as root user
base-image-amd64-root-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD)/docker/checks/image_processors.sh:/root/image_processors.sh \
		--user root \
		$(IMAGE_NAME):amd64 \
		/bin/bash

# Test image processors on ARM64 image
base-image-arm64-images-test:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD)/docker/checks/image_processors.sh:/root/image_processors.sh \
		--user root \
		$(IMAGE_NAME):arm64 \
		/bin/bash -c "source /root/image_processors.sh"

# Test image processors on AMD64 image
base-image-amd64-images-test:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD)/docker/checks/image_processors.sh:/root/image_processors.sh \
		--user root \
		$(IMAGE_NAME):amd64 \
		/bin/bash -c "source /root/image_processors.sh"

# Test image processors on both architectures
base-images-images-test:
	@echo "Testing image processors on ARM64..."
	make base-image-arm64-images-test
	@echo "Testing image processors on AMD64..."
	make base-image-amd64-images-test

# Clean all docker images related to this project
base-images-clean:
	@echo "Cleaning all base images..."
	@echo "Removing tagged images..."
	-docker rmi $(IMAGE_NAME):arm64 $(IMAGE_NAME):amd64 $(IMAGE_NAME):latest
	@echo "Removing all dangling images (intermediate build layers)..."
	-docker image prune -af
	@echo "Base images cleanup completed!"

# ===============================================================
# Buildx commands (modern multi-architecture approach)
# ===============================================================

# Setup buildx builder for multi-platform builds
base-images-buildx-setup:
	docker buildx create --name rails-start-builder --driver docker-container --bootstrap --use || true
	docker buildx use rails-start-builder

# Check buildx builder status
base-images-buildx-status:
	docker buildx ls
	docker buildx inspect rails-start-builder

# Remove buildx builder
base-images-buildx-cleanup:
	@echo "Removing buildx builder..."
	-docker buildx rm rails-start-builder
	@echo "Buildx builder cleanup completed!"

# Build multi-architecture base image using buildx (local only)
base-images-buildx:
	make base-images-buildx-setup
	docker buildx build \
		--builder rails-start-builder \
		-f $(BASE_DOCKERFILE) \
		--platform linux/arm64,linux/amd64 \
		--build-arg RUBY_VERSION="$(RUBY_VERSION)" \
		-t $(IMAGE_NAME):latest \
		.

# Build and push multi-architecture base image using buildx
base-images-buildx-push:
	make base-images-buildx-setup
	docker buildx build \
		--builder rails-start-builder \
		-f $(BASE_DOCKERFILE) \
		--platform linux/arm64,linux/amd64 \
		--build-arg RUBY_VERSION="$(RUBY_VERSION)" \
		-t $(IMAGE_NAME):latest \
		--push \
		.

# Complete buildx workflow: build and push multi-architecture base image
base-images-buildx-update:
	make base-images-buildx-push
	@echo "Multi-architecture base image built and pushed successfully!"

# Help for base image building commands
base-images-help:
	@echo "=============================================================="
	@echo "Base image building commands:"
	@echo "=============================================================="
	@echo "Single architecture commands (base-image-*):"
	@echo "  make base-image-arm64-build         - Build base image for ARM64"
	@echo "  make base-image-amd64-build         - Build base image for AMD64"
	@echo "  make base-image-arm64-shell         - Enter shell of base ARM64 image as rails user"
	@echo "  make base-image-amd64-shell         - Enter shell of base AMD64 image as rails user"
	@echo "  make base-image-arm64-root-shell    - Enter shell of base ARM64 image as root user"
	@echo "  make base-image-amd64-root-shell    - Enter shell of base AMD64 image as root user"
	@echo "  make base-image-arm64-images-test   - Test image processors on ARM64 image"
	@echo "  make base-image-amd64-images-test   - Test image processors on AMD64 image"
	@echo ""
	@echo "Multi-architecture commands (base-images-*):"
	@echo "  make base-images-build              - Build base image for all platforms"
	@echo "  make base-images-manifest-create    - Create manifest for base image"
	@echo "  make base-images-push               - Push base images to Docker Hub"
	@echo "  make base-images-manifest-push      - Push manifest to Docker Hub"
	@echo "  make base-images-images-test        - Test image processors on both architectures"
	@echo "  make base-images-clean              - Remove all base project images"
	@echo ""
	@echo "Buildx commands (modern multi-architecture approach):"
	@echo "  make base-images-buildx-setup       - Setup buildx builder for multi-platform builds"
	@echo "  make base-images-buildx-status      - Check buildx builder status and details"
	@echo "  make base-images-buildx-cleanup     - Remove buildx builder"
	@echo "  make base-images-buildx             - Build multi-arch base image with buildx (local)"
	@echo "  make base-images-buildx-push        - Build and push multi-arch base image with buildx"
	@echo "  make base-images-buildx-update      - Complete buildx workflow (build and push)"
	@echo ""
	@echo "Complete workflow:"
	@echo "  make base-images-update             - Build, push images and manifest (traditional)"
	@echo "  make base-images-buildx-update      - Build and push with buildx (modern)"
	@echo "=============================================================="