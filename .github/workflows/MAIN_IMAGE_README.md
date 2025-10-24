# Main Rails Docker Image Build Workflows

Two GitHub Actions workflows for automatic building and publishing Main Rails image in multi-arch (ARM64, AMD64, and ARM/v7).

## 🎯 Key Feature: Flexible Base Image Selection

Main image can be built from **two different sources**:

- **GHCR** (GitHub Container Registry): `ghcr.io/the-teacher/rails-start.base:latest`
- **Docker Hub**: `iamteacher/rails-start.base:latest`

---

## 📋 Workflows

### 1. `docker-main-image.yml` - GHCR (GitHub Container Registry)

**Triggers:**

- 🔄 Push to `main` or `master` branches (if files in `docker/IMAGES/` changed)
- 🔄 Pull Request to `main` or `master` branches
- ⚙️ Manual run (workflow_dispatch) - allows selecting base image source

**What it does:**

- ✅ Builds image for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`
- 📤 Pushes to GitHub Container Registry (ghcr.io)
- 💾 Caches layers to speed up future builds
- 🏷️ Automatically generates tags (branch, SHA, latest)
- 🔀 Allows choosing base image source (GHCR or Docker Hub)

**Default behavior:**

- Uses **GHCR Base image** (`ghcr.io/the-teacher/rails-start.base:latest`)
- Can be changed via **workflow_dispatch** manual run

**Generated tags:**

```
ghcr.io/the-teacher/rails-start.main:master          # branch tag
ghcr.io/the-teacher/rails-start.main:master-abc1234  # commit SHA
ghcr.io/the-teacher/rails-start.main:latest          # for default branch
```

**Usage:**

```bash
# Pull the image
docker pull ghcr.io/the-teacher/rails-start.main:latest

# Use in Dockerfile
FROM ghcr.io/the-teacher/rails-start.main:latest
```

---

### 2. `docker-main-hub.yml` - Docker Hub

**Triggers:**

- ⚙️ Manual run only (workflow_dispatch)

**What it does:**

- ✅ Builds image for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`
- 📤 Pushes to Docker Hub
- 🔀 Allows choosing base image source (GHCR or Docker Hub)

**Allows selecting:**

```
Base image source:
  - dockerhub: use iamteacher/rails-start.base:latest
  - ghcr: use ghcr.io/the-teacher/rails-start.base:latest
```

**Usage:**

```bash
# 1. Go to GitHub → Actions
# 2. Select "Build and Push Main Image to Docker Hub"
# 3. Click "Run workflow"
# 4. Choose:
#    - Tag: (e.g., v1.0.0, latest)
#    - Base image source: (dockerhub or ghcr)
# 5. Click "Run workflow"
```

---

## 🔐 Required Secrets

### For Docker Hub (if using `docker-main-hub.yml`)

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

| Architecture     | Usage                                  |
| ---------------- | -------------------------------------- |
| **linux/amd64**  | Intel/AMD 64-bit (desktops, servers)   |
| **linux/arm64**  | ARM 64-bit (M1/M2 Mac, modern servers) |
| **linux/arm/v7** | ARM 32-bit (Raspberry Pi, legacy ARM)  |

---

## 📊 Workflow Comparison

| Feature                  | GHCR                 | Docker Hub               |
| ------------------------ | -------------------- | ------------------------ |
| **Registry**             | GitHub               | Docker Hub               |
| **Trigger**              | Push (auto) + Manual | Manual only              |
| **Base image selection** | Yes (GHCR default)   | Yes (Docker Hub default) |
| **Automatic**            | Yes (every push)     | No (manual)              |
| **Availability**         | github.com users     | Everyone (public)        |
| **Ideal for**            | Development          | Release                  |

---

## 🚀 Typical Workflow

### Development (GHCR)

```bash
# Improve Main Dockerfile
git commit -am "Add new tools to Main image"
git push origin master

# → GHA automatically (using GHCR base):
# 1. Pulls ghcr.io/the-teacher/rails-start.base:latest
# 2. Builds image for arm64 + amd64 + arm/v7
# 3. Pushes to ghcr.io
# 4. Caches layers
```

### Release (Docker Hub)

```bash
# 1. Go to GitHub Actions
# 2. Run "Build and Push Main Image to Docker Hub" manually
# 3. Choose:
#    - Tag: v1.0.0
#    - Base image: dockerhub (or ghcr)
# 4. Workflow builds and pushes to Docker Hub
```

---

## 🛠️ Local Building with Makefile

### Default (Docker Hub base):

```bash
cd docker/IMAGES

# Build for all platforms
make main-images-buildx-update

# Or build for specific architecture
make main-image-arm64-build
make main-image-amd64-build
```

### Using GHCR base:

```bash
cd docker/IMAGES

# Build for all platforms with GHCR base
make main-images-buildx-push BASE_IMAGE_SOURCE=ghcr

# Or single architecture
make main-image-arm64-build BASE_IMAGE_SOURCE=ghcr
make main-image-amd64-build BASE_IMAGE_SOURCE=ghcr
```

### Run interactive shell:

```bash
# With Docker Hub base
make main-image-arm64-shell

# With GHCR base
make main-image-arm64-shell BASE_IMAGE_SOURCE=ghcr

# As root user
make main-image-arm64-root-shell BASE_IMAGE_SOURCE=ghcr
```

---

## 🔧 Environment Variables

### Base image source selection:

```bash
# Docker Hub (default)
BASE_IMAGE_SOURCE=dockerhub
# Results in: iamteacher/rails-start.base:latest

# GitHub Container Registry
BASE_IMAGE_SOURCE=ghcr
# Results in: ghcr.io/the-teacher/rails-start.base:latest
```

### In Dockerfile:

```dockerfile
ARG BASE_IMAGE=iamteacher/rails-start.base:latest
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
docker pull ghcr.io/the-teacher/rails-start.main:latest
docker run --rm -it ghcr.io/the-teacher/rails-start.main:latest /bin/bash

# Check Ruby version
docker run --rm ghcr.io/the-teacher/rails-start.main:latest ruby -v

# Check Node version
docker run --rm ghcr.io/the-teacher/rails-start.main:latest node -v
```

### Verify base image used

```bash
# Check image layers to see which base was used
docker history ghcr.io/the-teacher/rails-start.main:latest
```

---

## 📝 Example usage in other workflows

```yaml
name: Build App Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - name: Build app from main image
        uses: docker/build-push-action@v6
        with:
          file: Dockerfile
          build-args: |
            BASE_IMAGE=ghcr.io/the-teacher/rails-start.main:latest
          push: true
```

---

## ✅ Checklist before using

- [ ] Both workflow files are in `.github/workflows/`
- [ ] (for Docker Hub) Added DOCKER_HUB_USERNAME and DOCKER_HUB_TOKEN secrets
- [ ] Path to Dockerfile is correct: `docker/IMAGES/_Main.Dockerfile`
- [ ] IMAGE_NAME in both files matches your repositories
- [ ] Dockerfile uses `ARG BASE_IMAGE=...` for flexibility
- [ ] Makefile updated with BASE_IMAGE_SOURCE variable

---

## 🎯 Advanced: Custom Build Commands

### Build for specific architecture with custom base:

```bash
cd docker/IMAGES

docker buildx build \
  --platform linux/arm64 \
  -f _Main.Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/the-teacher/rails-start.base:latest \
  -t iamteacher/rails-start.main:custom \
  .
```

### Build all architectures and push:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -f _Main.Dockerfile \
  --build-arg BASE_IMAGE=ghcr.io/the-teacher/rails-start.base:latest \
  -t ghcr.io/the-teacher/rails-start.main:latest \
  --push \
  .
```

---

## 🔄 Multi-Architecture process

Both workflows use:

1. **QEMU** - ARM emulation on Linux
2. **Docker Buildx** - native multi-platform builder
3. **Caching** - speed up repeated builds
4. **Flexible base** - choose source (GHCR or Docker Hub)

Result: single image works on all architectures identically! ✅
