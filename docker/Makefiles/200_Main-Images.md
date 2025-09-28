# Main Images Makefile Commands

Documentation for all make commands in `Makefiles/200_Main-Images.mk` (executed from project root).

## Main Commands

| Command                          | Description                                        |
| -------------------------------- | -------------------------------------------------- |
| `make help`                      | Show main help                                     |
| `make main-images-help`          | Show main images commands help                     |
| `make main-images-update`        | Complete workflow: build, push images and manifest |
| `make main-images-buildx-update` | Complete buildx workflow (modern approach)         |

## Single Architecture Commands

### Build Commands

| Command                       | Description                |
| ----------------------------- | -------------------------- |
| `make main-image-arm64-build` | Build main image for ARM64 |
| `make main-image-amd64-build` | Build main image for AMD64 |

### Shell Access

| Command                            | Description                                  |
| ---------------------------------- | -------------------------------------------- |
| `make main-image-arm64-shell`      | Enter shell of main ARM64 image              |
| `make main-image-amd64-shell`      | Enter shell of main AMD64 image              |
| `make main-image-arm64-root-shell` | Enter shell of main ARM64 image as root user |
| `make main-image-amd64-root-shell` | Enter shell of main AMD64 image as root user |

### Rails Application

| Command                           | Description                      |
| --------------------------------- | -------------------------------- |
| `make main-image-arm64-rails-run` | Run Rails app in ARM64 container |
| `make main-image-amd64-rails-run` | Run Rails app in AMD64 container |

## Multi-Architecture Commands

### Build and Management

| Command                  | Description                            |
| ------------------------ | -------------------------------------- |
| `make main-images-build` | Build main image for all platforms     |
| `make main-images-clean` | Remove all main project images         |
| `make main-images-pull`  | Pull latest main image from Docker Hub |

### Registry Operations

| Command                            | Description                    |
| ---------------------------------- | ------------------------------ |
| `make main-images-push`            | Push main images to Docker Hub |
| `make main-images-manifest-create` | Create manifest for main image |
| `make main-images-manifest-push`   | Push manifest to Docker Hub    |

### Complete Workflows

| Command                   | Description                                   |
| ------------------------- | --------------------------------------------- |
| `make main-images-update` | Build, push images and manifest (traditional) |

## Buildx Commands (Modern Multi-Architecture)

### Setup and Management

| Command                           | Description                                    |
| --------------------------------- | ---------------------------------------------- |
| `make main-images-buildx-setup`   | Setup buildx builder for multi-platform builds |
| `make main-images-buildx-status`  | Check buildx builder status and details        |
| `make main-images-buildx-cleanup` | Remove buildx builder                          |

### Build Operations

| Command                        | Description                                  |
| ------------------------------ | -------------------------------------------- |
| `make main-images-buildx`      | Build multi-arch image using buildx (local)  |
| `make main-images-buildx-push` | Build and push multi-arch image using buildx |

### Complete Workflows

| Command                          | Description                               |
| -------------------------------- | ----------------------------------------- |
| `make main-images-buildx-update` | Complete buildx workflow (build and push) |

## Configuration

### Variables

| Variable          | Default Value                 | Description             |
| ----------------- | ----------------------------- | ----------------------- |
| `MAIN_DOCKERFILE` | `docker/_Main.Dockerfile`     | Path to main Dockerfile |
| `MAIN_IMAGE_NAME` | `iamteacher/rails-start.main` | Docker image name       |

## Usage Examples

### Traditional Multi-Architecture Build

```bash
make main-images-build           # Build for both architectures
make main-images-push            # Push to registry
make main-images-manifest-create # Create manifest
make main-images-manifest-push   # Push manifest
```

### Modern Buildx Approach

```bash
make main-images-buildx-update   # Complete buildx workflow
```

### Development and Testing

```bash
make main-image-arm64-build      # Build ARM64 image
make main-image-arm64-shell      # Test in shell
make main-image-arm64-rails-run  # Run Rails app
```

### Working with Registry

```bash
make main-images-pull            # Pull latest from registry
make main-images-push            # Push to registry
```

### Cleanup

```bash
make main-images-clean           # Clean local images
make main-images-buildx-cleanup  # Clean buildx builder
```

## Architecture Support

- **ARM64** (Apple Silicon, ARM servers)
- **AMD64** (Intel/AMD x86_64)
- **Multi-platform** manifests for cross-platform compatibility

## Registry

Images are pushed to Docker Hub:

- `iamteacher/rails-start.main:arm64`
- `iamteacher/rails-start.main:amd64`
- `iamteacher/rails-start.main:latest` (manifest)

## Features

- **Volume mounting** of project directory to `/app`
- **Port mapping** 3000:3000 for Rails applications
- **Automatic bundle install** and Rails server startup
- **Multi-user support** (rails user and root user access)
- **Based on base image** from `100_Base-Images.mk`
