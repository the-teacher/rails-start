# Media Docker Image Build Workflows

Two GitHub Actions workflows for automatic building and publishing Media image (ImageMagick, ffmpeg, and image optimization tools) in multi-arch (ARM64 and AMD64).

## 🎯 Key Feature: Flexible Main Image Selection

Media image can be built from **two different sources**:

- **GHCR** (GitHub Container Registry): `ghcr.io/the-teacher/rails-start.main:latest`
- **Docker Hub**: `iamteacher/rails-start.main:latest`

---

## 📋 Workflows

### 1. `docker-media-image.yml` - GHCR (GitHub Container Registry)

**Triggers (in priority order):**

1. ⏳ **After Main Image Build** (`workflow_run`)

   - Waits for `Build and Push Main Docker Image` to complete successfully
   - Automatically starts building Media after Main is ready
   - Ensures Media uses fresh Main image

2. 🔄 **Push to branch** (when Media or workflow files change)

   - Direct trigger if Main hasn't changed

3. ⚙️ **Manual run** (workflow_dispatch)
   - Choose main image source manually

**What it does:**

- ✅ Builds image for `linux/amd64` and `linux/arm64`
- 📤 Pushes to GitHub Container Registry (ghcr.io)
- 💾 Caches layers to speed up future builds
- 🏷️ Automatically generates tags (branch, SHA, latest)
- 🔀 Allows choosing main image source (GHCR or Docker Hub)

**Default behavior:**

- Uses **GHCR Main image** (`ghcr.io/the-teacher/rails-start.main:latest`)
- Can be changed via **workflow_dispatch** manual run

**Generated tags:**

```
ghcr.io/the-teacher/rails-start.media:master          # branch tag
ghcr.io/the-teacher/rails-start.media:master-abc1234  # commit SHA
ghcr.io/the-teacher/rails-start.media:latest          # for default branch
```

**Usage:**

```bash
# Pull the image
docker pull ghcr.io/the-teacher/rails-start.media:latest

# Use in Dockerfile
FROM ghcr.io/the-teacher/rails-start.media:latest
```

---

### 2. `docker-media-hub.yml` - Docker Hub

**Triggers:**

- ⚙️ Manual run only (workflow_dispatch)

**What it does:**

- ✅ Builds image for `linux/amd64` and `linux/arm64`
- 📤 Pushes to Docker Hub
- 🔀 Allows choosing main image source (GHCR or Docker Hub)

**Allows selecting:**

```
Main image source:
  - dockerhub: use iamteacher/rails-start.main:latest
  - ghcr: use ghcr.io/the-teacher/rails-start.main:latest
```

**Usage:**

```bash
# 1. Go to GitHub → Actions
# 2. Select "Build and Push Media Image to Docker Hub"
# 3. Click "Run workflow"
# 4. Choose:
#    - Tag: (e.g., v1.0.0, latest)
#    - Main image source: (dockerhub or ghcr)
# 5. Click "Run workflow"
```

---

## 📦 What's Inside Media Image

The Media image includes pre-compiled media processing tools in separate build stages:

- **ImageMagick** - image manipulation and conversion
- **FFmpeg** - video processing and encoding
- **libheif** - HEIF/HEIC image support
- **libwebp** - WebP image format support
- **openjp2** - JPEG2000 support
- **oxipng** - PNG optimization
- **pngquant** - PNG quantization
- **jpegoptim** - JPEG optimization
- **gifsicle** - GIF manipulation
- **cwebp** - WebP conversion tool
- **optipng** - PNG optimization
- Plus all utilities from the Main image (Ruby, Node.js, Rails, etc.)

This is a **12+ stage build** that compiles each tool separately to minimize the final image size.

---

## 🔐 Required Secrets

### For Docker Hub (if using `docker-media-hub.yml`)

In Settings → Secrets and variables → Actions add:

1. **DOCKER_HUB_USERNAME**

   - Your Docker Hub username

2. **DOCKER_HUB_TOKEN**
   - Access Token (create at https://hub.docker.com/settings/security)
   - ⚠️ DO NOT use password!

### For GHCR (GitHub Container Registry)

Uses `${{ secrets.GITHUB_TOKEN }}` - automatically available.

---

## 🏗️ Supported Architectures

| Architecture    | Usage                                  |
| --------------- | -------------------------------------- |
| **linux/amd64** | Intel/AMD 64-bit (desktops, servers)   |
| **linux/arm64** | ARM 64-bit (M1/M2 Mac, modern servers) |

---

## 📊 Workflow Comparison

| Feature                  | GHCR                 | Docker Hub               |
| ------------------------ | -------------------- | ------------------------ |
| **Registry**             | GitHub               | Docker Hub               |
| **Trigger**              | Push (auto) + Manual | Manual only              |
| **Main image selection** | Yes (GHCR default)   | Yes (Docker Hub default) |
| **Automatic**            | Yes (every push)     | No (manual)              |
| **Availability**         | github.com users     | Everyone (public)        |
| **Ideal for**            | Development          | Release                  |

---

## 🚀 Typical Workflow

### Automatic Build Chain (Recommended)

```
1. You push changes to docker/IMAGES/_Main.Dockerfile or _Media.Dockerfile
   ↓
2. GitHub automatically triggers Base workflow (if Base changed)
   ↓
3. Base image builds for arm64 + amd64 and pushes to ghcr.io
   ↓
4. Main workflow AUTOMATICALLY triggered after Base (workflow_run)
   ↓
5. Main image builds using fresh Base image
   ↓
6. Main image pushes to ghcr.io successfully
   ↓
7. Media workflow AUTOMATICALLY triggered after Main (workflow_run)
   ↓
8. Media image builds using fresh Main image
   ↓
9. Media image pushes to ghcr.io
```

**Result:** Full build chain: Base → Main → Media! ✅

### Development (GHCR)

```bash
# Improve Media Dockerfile (add new tools, optimize)
git commit -am "Add new media processing tools"
git push origin master

# → GHA automatically:
# 1. Detects Media Dockerfile change
# 2. Triggers Media workflow
# 3. Builds Media image for arm64 + amd64
# 4. Pushes to ghcr.io
```

### Manual Build with specific Main source

```bash
# If you want to rebuild Media with specific Main source:
# 1. GitHub → Actions
# 2. "Build and Push Media Docker Image"
# 3. "Run workflow"
# 4. Choose Main image source (ghcr or dockerhub)
# 5. "Run workflow"
```

### Release (Docker Hub)

```bash
# 1. Go to GitHub Actions
# 2. Run "Build and Push Media Image to Docker Hub" manually
# 3. Choose:
#    - Tag: v1.0.0
#    - Main image: dockerhub (or ghcr)
# 4. Workflow builds and pushes to Docker Hub
```

---

## 🛠️ Local Building with Makefile

### Default (Docker Hub main):

```bash
cd docker/IMAGES

# Build for all platforms
make media-images-buildx-update

# Or build for specific architecture
make media-image-arm64-build
make media-image-amd64-build
```

### Using GHCR main:

```bash
cd docker/IMAGES

# Build for all platforms with GHCR main
make media-images-buildx-push MAIN_IMAGE_SOURCE=ghcr

# Or single architecture
make media-image-arm64-build MAIN_IMAGE_SOURCE=ghcr
make media-image-amd64-build MAIN_IMAGE_SOURCE=ghcr
```

### Run interactive shell:

```bash
# With Docker Hub main
make media-image-arm64-shell

# With GHCR main
make media-image-arm64-shell MAIN_IMAGE_SOURCE=ghcr

# As root user
make media-image-arm64-root-shell MAIN_IMAGE_SOURCE=ghcr
```

---

## 🔧 Environment Variables

### Main image source selection:

```bash
# Docker Hub (default)
MAIN_IMAGE_SOURCE=dockerhub
# Results in: iamteacher/rails-start.main:latest

# GitHub Container Registry
MAIN_IMAGE_SOURCE=ghcr
# Results in: ghcr.io/the-teacher/rails-start.main:latest
```

### In Dockerfile:

```dockerfile
ARG BASE_IMAGE=iamteacher/rails-start.main:latest
FROM ${BASE_IMAGE}
```

---

## 🐛 Troubleshooting

### View workflow logs

1. Go to **Actions** tab
2. Select workflow
3. Click on specific run
4. View logs for each step

### Test image locally

```bash
# Pull and test
docker pull ghcr.io/the-teacher/rails-start.media:latest
docker run --rm -it ghcr.io/the-teacher/rails-start.media:latest /bin/bash

# Check installed tools
docker run --rm ghcr.io/the-teacher/rails-start.media:latest convert --version
docker run --rm ghcr.io/the-teacher/rails-start.media:latest ffmpeg -version
docker run --rm ghcr.io/the-teacher/rails-start.media:latest identify -version

# Check Ruby version
docker run --rm ghcr.io/the-teacher/rails-start.media:latest ruby -v

# Check Node version
docker run --rm ghcr.io/the-teacher/rails-start.media:latest node -v
```

### Verify main image used

```bash
# Check image layers to see which main was used
docker history ghcr.io/the-teacher/rails-start.media:latest
```

### Build times

Media image takes significantly longer to build due to compiling many tools. First build may take 30-60 minutes depending on machine. Subsequent builds use layer caching and should be faster.

---

## 📝 Example usage in other workflows

```yaml
name: Build App with Media Processing

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - name: Build app from media image
        uses: docker/build-push-action@v6
        with:
          file: Dockerfile
          build-args: |
            BASE_IMAGE=ghcr.io/the-teacher/rails-start.media:latest
          push: true
```

---

## ✅ Checklist before using

- [ ] Both workflow files are in `.github/workflows/`
- [ ] (for Docker Hub) Added DOCKER_HUB_USERNAME and DOCKER_HUB_TOKEN secrets
- [ ] Path to Dockerfile is correct: `docker/IMAGES/_Media.Dockerfile`
- [ ] IMAGE_NAME in both files matches your repositories
- [ ] Dockerfile uses `ARG BASE_IMAGE=...` for flexibility
- [ ] Makefile updated with MAIN_IMAGE_SOURCE variable
- [ ] Media workflow depends on Main workflow (workflow_run trigger)

---

## 🎯 Advanced: Custom Build Commands

### Build for specific architecture with custom main:

```bash
cd docker/IMAGES

docker buildx build \
  --platform linux/arm64 \
  -f _Media.Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/the-teacher/rails-start.main:latest \
  -t iamteacher/rails-start.media:custom \
  .
```

### Build all architectures and push:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f _Media.Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/the-teacher/rails-start.main:latest \
  -t ghcr.io/the-teacher/rails-start.media:latest \
  --push \
  .
```

### Building without cache (fresh compile):

```bash
# This forces all media tools to be recompiled
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f _Media.Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/the-teacher/rails-start.main:latest \
  --no-cache \
  -t ghcr.io/the-teacher/rails-start.media:fresh \
  --push \
  .
```

---

## 🔄 Multi-Architecture process

Both workflows use:

1. **QEMU** - ARM emulation on Linux
2. **Docker Buildx** - native multi-platform builder
3. **Caching** - speed up repeated builds
4. **Flexible main** - choose source (GHCR or Docker Hub)

Result: single image works on all architectures identically! ✅

---

## 🔗 Build Chain Architecture

```
Base Image
├─ Purpose: Essential utilities, compilers
├─ Architectures: linux/amd64, linux/arm64
├─ Registry: GHCR + Docker Hub
└─ Trigger: Push to _Base.Dockerfile

Main Image (depends on Base)
├─ Purpose: Rails development environment
├─ Architectures: linux/amd64, linux/arm64
├─ Registry: GHCR + Docker Hub
├─ Trigger: workflow_run after Base
└─ Source selection: Base image (GHCR or Docker Hub)

Media Image (depends on Main)
├─ Purpose: Media processing tools
├─ Architectures: linux/amd64, linux/arm64
├─ Registry: GHCR + Docker Hub
├─ Trigger: workflow_run after Main
└─ Source selection: Main image (GHCR or Docker Hub)
```

This three-tier architecture ensures:
- ✅ Modular builds (changes don't rebuild everything)
- ✅ Fresh dependencies (Media gets latest Main gets latest Base)
- ✅ Flexible sourcing (can mix GHCR and Docker Hub)
- ✅ Multi-arch support (same image runs on all platforms)

---

## 📚 Related Documentation

- **Base Image Workflows**: See [BASE_IMAGE_README.md](./BASE_IMAGE_README.md)
- **Main Image Workflows**: See [MAIN_IMAGE_README.md](./MAIN_IMAGE_README.md)
- **Dockerfile Reference**: [docker/IMAGES/_Media.Dockerfile](../../docker/IMAGES/_Media.Dockerfile)
- **Build Commands**: [docker/IMAGES/Makefiles/300_Media-Images.mk](../../docker/IMAGES/Makefiles/300_Media-Images.mk)
