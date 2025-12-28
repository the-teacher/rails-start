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
# https://hub.docker.com/r/iamteacher/rails-start.media/tags
# ===============================================================

# ===============================================================
# Media Image (Using Main Image)
# ===============================================================
MEDIA_DOCKERFILE = ./_Media.Dockerfile
MEDIA_IMAGE_NAME = iamteacher/rails-start.media
MEDIA_DOCKER_HUB_REPO = iamteacher/rails-start.media
MEDIA_GITHUB_REPO = ghcr.io/the-teacher/rails-start.media

# Main image source (can be 'dockerhub' or 'ghcr')
# dockerhub: iamteacher/rails-start.main:latest (Docker Hub)
# ghcr: ghcr.io/the-teacher/rails-start.main:latest (GitHub Container Registry)
MAIN_IMAGE_SOURCE ?= dockerhub

ifeq ($(MAIN_IMAGE_SOURCE), ghcr)
  MAIN_IMAGE = ghcr.io/the-teacher/rails-start.main:latest
else
  MAIN_IMAGE = iamteacher/rails-start.main:latest
endif

# Build media image for ARM64
media-image-arm64-build:
	docker build \
		-t $(MEDIA_IMAGE_NAME):arm64 \
		-f $(MEDIA_DOCKERFILE) \
		--platform linux/arm64 \
		--build-arg TARGETPLATFORM="linux/arm64" \
		--build-arg TARGETARCH="arm64" \
		--build-arg BASE_IMAGE=$(MAIN_IMAGE) \
		.

# Build media image for AMD64
media-image-amd64-build:
	docker build \
		-t $(MEDIA_IMAGE_NAME):amd64 \
		-f $(MEDIA_DOCKERFILE) \
		--platform linux/amd64 \
		--build-arg TARGETPLATFORM="linux/amd64" \
		--build-arg TARGETARCH="amd64" \
		--build-arg BASE_IMAGE=$(MAIN_IMAGE) \
		.

# Build media images for all platforms
media-images-build:
	make media-image-arm64-build
	make media-image-amd64-build

# Create manifest for media image
media-images-manifest-create:
	docker manifest create \
		$(MEDIA_IMAGE_NAME):latest \
		--amend $(MEDIA_IMAGE_NAME):arm64 \
		--amend $(MEDIA_IMAGE_NAME):amd64

# Push media images to Docker Hub
media-images-push:
	docker push $(MEDIA_IMAGE_NAME):arm64
	docker push $(MEDIA_IMAGE_NAME):amd64

# Push media image manifest to Docker Hub
media-images-manifest-push:
	make media-images-push
	docker manifest push --purge $(MEDIA_IMAGE_NAME):latest

# Complete workflow for building and publishing media images
media-images-update:
	make media-images-build
	make media-images-push
	make media-images-manifest-create
	make media-images-manifest-push
	@echo "Media images built and published successfully!"

# Run shell in ARM64 media image
media-image-arm64-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		$(MEDIA_IMAGE_NAME):arm64 \
		/bin/bash

# Run shell in AMD64 media image
media-image-amd64-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		$(MEDIA_IMAGE_NAME):amd64 \
		/bin/bash

# Enter shell of the latest ARM64 media image as root user
media-image-arm64-root-shell:
	docker run --rm -it \
		--platform linux/arm64 \
		-v $(PWD):/app \
		--user root \
		$(MEDIA_IMAGE_NAME):arm64 \
		/bin/bash

# Enter shell of the latest AMD64 media image as root user
media-image-amd64-root-shell:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD):/app \
		--user root \
		$(MEDIA_IMAGE_NAME):amd64 \
		/bin/bash

# Clean media docker images related to this project
media-images-clean:
	@echo "Cleaning media images..."
	@echo "Removing tagged images..."
	-docker rmi $(MEDIA_IMAGE_NAME):arm64 $(MEDIA_IMAGE_NAME):amd64 $(MEDIA_IMAGE_NAME):latest
	@echo "Media images cleanup completed!"

media-images-pull:
	@echo "Pulling latest media image from Docker Hub..."
	docker pull $(MEDIA_IMAGE_NAME):latest
	@echo "Media images pulled successfully!"

# Download the most recent version of media images and check architecture
media-images-arch-check:
	@echo "=============================================================="
	@echo "Checking architectures of media images"
	@echo "=============================================================="
	@echo ""
	@echo "Cleaning up old local images..."
	-docker rmi $(MEDIA_DOCKER_HUB_REPO):latest $(MEDIA_DOCKER_HUB_REPO):arm64 $(MEDIA_DOCKER_HUB_REPO):amd64 2>/dev/null || true
	-docker rmi $(MEDIA_GITHUB_REPO):latest $(MEDIA_GITHUB_REPO):arm64 $(MEDIA_GITHUB_REPO):amd64 2>/dev/null || true
	@echo ""
	@echo "Pulling latest images from Docker Hub..."
	@echo "--------------------------------------------------------------"
	docker pull --platform linux/arm64 $(MEDIA_DOCKER_HUB_REPO):latest
	docker pull --platform linux/amd64 $(MEDIA_DOCKER_HUB_REPO):latest
	@echo ""
	@echo "Pulling latest images from GitHub Container Registry..."
	@echo "--------------------------------------------------------------"
	docker pull --platform linux/arm64 $(MEDIA_GITHUB_REPO):latest
	docker pull --platform linux/amd64 $(MEDIA_GITHUB_REPO):latest
	@echo ""
	@echo "=============================================================="
	@echo "Architecture verification results:"
	@echo "=============================================================="
	@echo ""
	@echo "Docker Hub (arm64):"
	@printf "  Expected: arm64 | Actual: "
	@docker inspect --format='{{.Architecture}}' $(MEDIA_DOCKER_HUB_REPO):latest | grep -q arm64 && echo "arm64 ✓" || (docker inspect --format='{{.Architecture}}' $(MEDIA_DOCKER_HUB_REPO):latest && echo "✗ MISMATCH!")
	@echo ""
	@echo "Docker Hub (amd64):"
	@printf "  Expected: amd64 | Actual: "
	@docker inspect --format='{{.Architecture}}' $(MEDIA_DOCKER_HUB_REPO):latest | grep -q amd64 && echo "amd64 ✓" || (docker inspect --format='{{.Architecture}}' $(MEDIA_DOCKER_HUB_REPO):latest && echo "✗ MISMATCH!")
	@echo ""
	@echo "GitHub Container Registry (arm64):"
	@printf "  Expected: arm64 | Actual: "
	@docker inspect --format='{{.Architecture}}' $(MEDIA_GITHUB_REPO):latest | grep -q arm64 && echo "arm64 ✓" || (docker inspect --format='{{.Architecture}}' $(MEDIA_GITHUB_REPO):latest && echo "✗ MISMATCH!")
	@echo ""
	@echo "GitHub Container Registry (amd64):"
	@printf "  Expected: amd64 | Actual: "
	@docker inspect --format='{{.Architecture}}' $(MEDIA_GITHUB_REPO):latest | grep -q amd64 && echo "amd64 ✓" || (docker inspect --format='{{.Architecture}}' $(MEDIA_GITHUB_REPO):latest && echo "✗ MISMATCH!")
	@echo ""
	@echo "=============================================================="
	@echo "Full manifest inspection:"
	@echo "=============================================================="
	@echo ""
	@echo "Docker Hub manifest:"
	@docker manifest inspect $(MEDIA_DOCKER_HUB_REPO):latest | grep -E '"architecture"|"os"'
	@echo ""
	@echo "GitHub Container Registry manifest:"
	@docker manifest inspect $(MEDIA_GITHUB_REPO):latest | grep -E '"architecture"|"os"'
	@echo ""
	@echo "=============================================================="

# ===============================================================
# Buildx commands (modern multi-architecture approach)
# ===============================================================

# Setup buildx builder for multi-platform builds
media-images-buildx-setup:
	docker buildx create --name rails-start-builder --driver docker-container --bootstrap --use || true
	docker buildx use rails-start-builder

# Check buildx builder status
media-images-buildx-status:
	docker buildx ls
	docker buildx inspect rails-start-builder

# Remove buildx builder
media-images-buildx-cleanup:
	@echo "Removing buildx builder..."
	-docker buildx rm rails-start-builder
	@echo "Buildx builder cleanup completed!"

# Build multi-architecture image using buildx (local only)
media-images-buildx:
	make media-images-buildx-setup
	docker buildx build \
		--builder rails-start-builder \
		-f $(MEDIA_DOCKERFILE) \
		--platform linux/arm64,linux/amd64 \
		--progress=plain \
		--build-arg BASE_IMAGE=$(MAIN_IMAGE) \
		-t $(MEDIA_IMAGE_NAME):latest \
		.

# Build and push multi-architecture image using buildx
media-images-buildx-push:
	make media-images-buildx-setup
	docker buildx build \
		--builder rails-start-builder \
		-f $(MEDIA_DOCKERFILE) \
		--platform linux/arm64,linux/amd64 \
		--progress=plain \
		--build-arg BASE_IMAGE=$(MAIN_IMAGE) \
		-t $(MEDIA_IMAGE_NAME):latest \
		--push \
		.

# Complete buildx workflow: build and push multi-architecture image
media-images-buildx-update:
	make media-images-buildx-push
	@echo "Multi-architecture media image built and pushed successfully!"

# Help for media image building commands
media-images-help:
	@echo "=============================================================="
	@echo "Media image building commands:"
	@echo "=============================================================="
	@echo ""
	@echo "Main image selection (set MAIN_IMAGE_SOURCE):"
	@echo "  make media-image-arm64-build MAIN_IMAGE_SOURCE=dockerhub"
	@echo "  make media-image-arm64-build MAIN_IMAGE_SOURCE=ghcr"
	@echo ""
	@echo "Single architecture commands (media-image-*):"
	@echo "  make media-image-arm64-build         - Build media image for ARM64"
	@echo "  make media-image-amd64-build         - Build media image for AMD64"
	@echo "  make media-image-arm64-shell         - Enter shell of media ARM64 image"
	@echo "  make media-image-amd64-shell         - Enter shell of media AMD64 image"
	@echo "  make media-image-arm64-root-shell    - Enter shell of media ARM64 image as root user"
	@echo "  make media-image-amd64-root-shell    - Enter shell of media AMD64 image as root user"
	@echo ""
	@echo "Multi-architecture commands (media-images-*):"
	@echo "  make media-images-build              - Build media image for all platforms"
	@echo "  make media-images-manifest-create    - Create manifest for media image"
	@echo "  make media-images-push               - Push media images to Docker Hub"
	@echo "  make media-images-manifest-push      - Push manifest to Docker Hub"
	@echo "  make media-images-clean              - Remove all media project images"
	@echo "  make media-images-arch-check         - Check architectures of media images"
	@echo ""
	@echo "Buildx commands (modern multi-arch approach):"
	@echo "  make media-images-buildx-setup       - Setup buildx builder for multi-platform builds"
	@echo "  make media-images-buildx-status      - Check buildx builder status and details"
	@echo "  make media-images-buildx-cleanup     - Remove buildx builder"
	@echo "  make media-images-buildx             - Build multi-arch image using buildx (local)"
	@echo "  make media-images-buildx-push        - Build and push multi-arch image using buildx"
	@echo "  make media-images-buildx-update      - Complete buildx workflow (build and push)"
	@echo ""
	@echo "Complete workflow:"
	@echo "  make media-images-update             - Build, push images and manifest (classic)"
	@echo "  make media-images-buildx-update      - Build and push multi-arch image (modern)"
	@echo ""
	@echo "Environment variables:"
	@echo "  MAIN_IMAGE_SOURCE=dockerhub          - Use Docker Hub main image (default)"
	@echo "  MAIN_IMAGE_SOURCE=ghcr               - Use GitHub Container Registry main image"
	@echo "=============================================================="