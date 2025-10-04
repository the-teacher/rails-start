# Common Images Makefile Commands

Documentation for all make commands in `Makefiles/300_Common-Images.mk` (executed from project root).

## Main Commands

| Command                    | Description                                       |
| -------------------------- | ------------------------------------------------- |
| `make help`                | Show main help                                    |
| `make common-images-help`  | Show common images commands help                  |
| `make common-images-clean` | Remove all project images (base, main, and media) |

## Image Verification Commands

### Base Images

| Command                         | Description                        |
| ------------------------------- | ---------------------------------- |
| `make common-images-base-check` | Check if base images exist locally |

### Main Images

| Command                         | Description                        |
| ------------------------------- | ---------------------------------- |
| `make common-images-main-check` | Check if main images exist locally |

### Media Images

| Command                          | Description                         |
| -------------------------------- | ----------------------------------- |
| `make common-images-media-check` | Check if media images exist locally |

### All Images

| Command                        | Description                       |
| ------------------------------ | --------------------------------- |
| `make common-images-check-all` | Check if all images exist locally |

## Image Size Commands

### Base Images

| Command                         | Description               |
| ------------------------------- | ------------------------- |
| `make common-images-base-sizes` | Show sizes of base images |

### Main Images

| Command                         | Description               |
| ------------------------------- | ------------------------- |
| `make common-images-main-sizes` | Show sizes of main images |

### Media Images

| Command                          | Description                |
| -------------------------------- | -------------------------- |
| `make common-images-media-sizes` | Show sizes of media images |

### All Images

| Command                        | Description                      |
| ------------------------------ | -------------------------------- |
| `make common-images-sizes-all` | Show sizes of all project images |

## Image Information Commands

| Command                       | Description            |
| ----------------------------- | ---------------------- |
| `make common-images-show-all` | Show all Docker images |

## Shortcuts

| Command             | Alias For                      | Description                       |
| ------------------- | ------------------------------ | --------------------------------- |
| `make images-check` | `make common-images-check-all` | Check if all images exist locally |
| `make images-sizes` | `make common-images-sizes-all` | Show sizes of all project images  |

## Cleanup Commands

| Command                    | Description                                       |
| -------------------------- | ------------------------------------------------- |
| `make common-images-clean` | Remove all project images (base, main, and media) |

## Configuration

### Variables

| Variable           | Default Value                  | Description             |
| ------------------ | ------------------------------ | ----------------------- |
| `BASE_IMAGE_NAME`  | `iamteacher/rails-start.base`  | Base Docker image name  |
| `MAIN_IMAGE_NAME`  | `iamteacher/rails-start.main`  | Main Docker image name  |
| `MEDIA_IMAGE_NAME` | `iamteacher/rails-start.media` | Media Docker image name |

### Image Tags Checked

| Image Type | ARM64 Tag                            | AMD64 Tag                            |
| ---------- | ------------------------------------ | ------------------------------------ |
| Base       | `iamteacher/rails-start.base:arm64`  | `iamteacher/rails-start.base:amd64`  |
| Main       | `iamteacher/rails-start.main:arm64`  | `iamteacher/rails-start.main:amd64`  |
| Media      | `iamteacher/rails-start.media:arm64` | `iamteacher/rails-start.media:amd64` |

## Usage Examples

### Verify Images Exist

```bash
make common-images-base-check    # Check base images
make common-images-main-check    # Check main images
make common-images-media-check   # Check media images
make common-images-check-all     # Check all images

# Or use shortcuts
make images-check                # Same as common-images-check-all
```

### Check Image Sizes

```bash
make common-images-base-sizes    # Base image sizes
make common-images-main-sizes    # Main image sizes
make common-images-media-sizes   # Media image sizes
make common-images-sizes-all     # All project image sizes

# Or use shortcuts
make images-sizes                # Same as common-images-sizes-all
```

### View and Cleanup

```bash
make common-images-show-all      # Show all Docker images
make common-images-clean         # Clean all project images
```

### Development Workflow

```bash
# Before building main images, verify base images exist
make common-images-base-check

# Before building media images, verify main images exist
make common-images-main-check

# After building all images, check sizes
make images-sizes

# Quick check of all images
make images-check

# Clean up when done
make common-images-clean
```

## Error Handling

### Missing Base Images

If base images don't exist, the system will show:

```
Error: Image iamteacher/rails-start.base:arm64 not found.
Run 'make base-image-arm64-build' first.
```

### Missing Main Images

If main images don't exist, the system will show:

```
Error: Image iamteacher/rails-start.main:arm64 not found.
Run 'make main-image-arm64-build' first.
```

### Missing Media Images

If media images don't exist, the system will show:

```
Error: Image iamteacher/rails-start.media:arm64 not found.
Run 'make media-image-arm64-build' first.
```

## Architecture Support

- **ARM64** (Apple Silicon, ARM servers)
- **AMD64** (Intel/AMD x86_64)
- **Cross-platform** verification and management

## Features

- **Dependency verification** - ensures required images exist before operations
- **Size reporting** - provides formatted table of image sizes
- **Unified cleanup** - removes all project-related images
- **Error guidance** - provides specific commands to fix missing images
- **Image inspection** - shows detailed image information including IDs and tags

## Integration

This file provides common utilities used by:

- `100_Base-Images.mk` - for base image operations
- `200_Main-Images.mk` - for main image operations
- `300_Media-Images.mk` - for media image operations
- Project workflows requiring image verification
