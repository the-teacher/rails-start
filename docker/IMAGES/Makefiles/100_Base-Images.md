# Base Images Makefile Commands

Documentation for all make commands in `Makefiles/100_Base-Images.mk` (executed from project root).

## Main Commands

| Command                          | Description                                        |
| -------------------------------- | -------------------------------------------------- |
| `make help`                      | Show main help                                     |
| `make base-images-help`          | Show base images commands help                     |
| `make base-images-update`        | Complete workflow: build, push images and manifest |
| `make base-images-buildx-update` | Complete buildx workflow (modern approach)         |

## Single Architecture Commands

### Build Commands

| Command                       | Description                |
| ----------------------------- | -------------------------- |
| `make base-image-arm64-build` | Build base image for ARM64 |
| `make base-image-amd64-build` | Build base image for AMD64 |

### Shell Access

| Command                            | Description                                   |
| ---------------------------------- | --------------------------------------------- |
| `make base-image-arm64-shell`      | Enter shell of base ARM64 image as rails user |
| `make base-image-amd64-shell`      | Enter shell of base AMD64 image as rails user |
| `make base-image-arm64-root-shell` | Enter shell of base ARM64 image as root user  |
| `make base-image-amd64-root-shell` | Enter shell of base AMD64 image as root user  |

### Testing

| Command                             | Description                          |
| ----------------------------------- | ------------------------------------ |
| `make base-image-arm64-images-test` | Test image processors on ARM64 image |
| `make base-image-amd64-images-test` | Test image processors on AMD64 image |

## Multi-Architecture Commands

### Build and Management

| Command                  | Description                        |
| ------------------------ | ---------------------------------- |
| `make base-images-build` | Build base image for all platforms |
| `make base-images-clean` | Remove all base project images     |

### Registry Operations

| Command                            | Description                    |
| ---------------------------------- | ------------------------------ |
| `make base-images-push`            | Push base images to Docker Hub |
| `make base-images-manifest-create` | Create manifest for base image |
| `make base-images-manifest-push`   | Push manifest to Docker Hub    |

### Testing

| Command                        | Description                                 |
| ------------------------------ | ------------------------------------------- |
| `make base-images-images-test` | Test image processors on both architectures |

### Complete Workflows

| Command                   | Description                                   |
| ------------------------- | --------------------------------------------- |
| `make base-images-update` | Build, push images and manifest (traditional) |

## Buildx Commands (Modern Multi-Architecture)

### Setup and Management

| Command                           | Description                                    |
| --------------------------------- | ---------------------------------------------- |
| `make base-images-buildx-setup`   | Setup buildx builder for multi-platform builds |
| `make base-images-buildx-status`  | Check buildx builder status and details        |
| `make base-images-buildx-cleanup` | Remove buildx builder                          |

### Build Operations

| Command                        | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `make base-images-buildx`      | Build multi-arch base image with buildx (local)  |
| `make base-images-buildx-push` | Build and push multi-arch base image with buildx |

### Complete Workflows

| Command                          | Description                               |
| -------------------------------- | ----------------------------------------- |
| `make base-images-buildx-update` | Complete buildx workflow (build and push) |

## Configuration

### Variables

| Variable          | Default Value                 | Description                 |
| ----------------- | ----------------------------- | --------------------------- |
| `BASE_DOCKERFILE` | `./_Base.Dockerfile`          | Path to base Dockerfile     |
| `IMAGE_NAME`      | `iamteacher/rails-start.base` | Docker image name           |
| `RUBY_VERSION`    | `3.4.6-bookworm`              | Ruby version for base image |

## Usage Examples

### Traditional Multi-Architecture Build

```bash
make base-images-build           # Build for both architectures
make base-images-push            # Push to registry
make base-images-manifest-create # Create manifest
make base-images-manifest-push   # Push manifest
```

### Modern Buildx Approach

```bash
make base-images-buildx-update   # Complete buildx workflow
```

### Development and Testing

```bash
make base-image-arm64-build      # Build ARM64 image
make base-image-arm64-shell      # Test in shell
make base-image-arm64-images-test # Test image processors
```

### Cleanup

```bash
make base-images-clean           # Clean local images
make base-images-buildx-cleanup  # Clean buildx builder
```

## Architecture Support

- **ARM64** (Apple Silicon, ARM servers)
- **AMD64** (Intel/AMD x86_64)
- **Multi-platform** manifests for cross-platform compatibility

## Registry

Images are pushed to Docker Hub:

- `iamteacher/rails-start.base:arm64`
- `iamteacher/rails-start.base:amd64`
- `iamteacher/rails-start.base:latest` (manifest)
