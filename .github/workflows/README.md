# Base Docker Image Build Workflows

Two GitHub Actions workflows for automatic building and publishing Base image in multi-arch (ARM64 and AMD64).

## 📋 Workflows

### 1. `docker-base-image.yml` - GHCR (GitHub Container Registry)

**Triggers:**

- 🔄 Push to `main` or `master` branches (if files in `docker/IMAGES/` changed)
- 🔄 Pull Request to `main` or `master` branches
- ⚙️ Manual run (workflow_dispatch)

**What it does:**

- ✅ Builds image for `linux/amd64` and `linux/arm64`
- 📤 Pushes to GitHub Container Registry (ghcr.io)
- 💾 Caches layers to speed up future builds
- 🏷️ Automatically generates tags (branch, SHA, latest)

**Generated tags:**

```
ghcr.io/the-teacher/rails-start.base:main          # branch tag
ghcr.io/the-teacher/rails-start.base:main-abc1234  # commit SHA
ghcr.io/the-teacher/rails-start.base:latest        # for default branch
```

**Usage:**

```bash
# Pull the image
docker pull ghcr.io/the-teacher/rails-start.base:latest

# Use in Dockerfile
FROM ghcr.io/the-teacher/rails-start.base:latest
```

---

### 2. `docker-base-hub.yml` - Docker Hub

**Triggers:**

- 🏷️ Tag push (v*, base-*)
- ⚙️ Manual run with tag parameter

**What it does:**

- ✅ Builds image for `linux/amd64` and `linux/arm64`
- 📤 Pushes to Docker Hub
- 🏷️ Automatically generates tags from git tags

**Requires secrets:**

```
DOCKER_HUB_USERNAME   # your Docker Hub username
DOCKER_HUB_TOKEN      # access token (not password!)
```

**Usage:**

```bash
# Create and push tag
git tag -a v1.0.0 -m "Base image v1.0.0"
git push origin v1.0.0

# This automatically runs the workflow and creates tags:
# - iamteacher/rails-start.base:v1.0.0
# - iamteacher/rails-start.base:latest
```

---

## 🔐 Required Secrets

### For Docker Hub (if using `docker-base-hub.yml`)

In Settings → Secrets and variables → Actions add:

1. **DOCKER_HUB_USERNAME**

   - Your Docker Hub username

2. **DOCKER_HUB_TOKEN**
   - Access Token (create at https://hub.docker.com/settings/security)
   - ⚠️ DO NOT use password!

### For GHCR (GitHub Container Registry)

Uses `${{ secrets.GITHUB_TOKEN }}` - automatically available.

---

## 📊 Comparison of two approaches

| Feature          | GHCR             | Docker Hub                   |
| ---------------- | ---------------- | ---------------------------- |
| **Registry**     | GitHub           | Docker Hub                   |
| **Trigger**      | Push to branch   | Git tags + manual run        |
| **Automatic**    | Yes (every push) | No (by tags)                 |
| **Versioning**   | By branch/SHA    | By semantic versioning       |
| **Availability** | github.com users | Everyone (public Docker Hub) |
| **Ideal for**    | Development      | Release/Production           |

---

## 🚀 Typical Workflow

### Development (GHCR)

```bash
# Improve Base Dockerfile
git commit -am "Add dnsutils to Base image"
git push origin main

# → GHA automatically:
# 1. Builds image for arm64 + amd64
# 2. Pushes to ghcr.io
# 3. Caches layers
```

### Release (Docker Hub)

```bash
# Ready for release
git tag -a base-v1.1.0 -m "Base image v1.1.0"
git push origin base-v1.1.0

# → GHA automatically:
# 1. Builds image for arm64 + amd64
# 2. Pushes to Docker Hub with tags v1.1.0 and latest
```

---

## 🐛 Troubleshooting

### View workflow logs

1. Go to **Actions** tab
2. Select workflow
3. Click on specific run
4. View logs for each step

### Check cache

```bash
# GHCR uses GitHub Actions cache
# If cleanup needed - delete old caches in Settings → Actions
```

### Test image locally

```bash
# Pull and test
docker pull ghcr.io/the-teacher/rails-start.base:latest
docker run --rm -it ghcr.io/the-teacher/rails-start.base:latest /bin/bash
```

---

## 📝 Example usage in other workflows

```yaml
name: Build Main App Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - name: Build app from base image
        uses: docker/build-push-action@v6
        with:
          file: Dockerfile
          build-args: |
            BASE_IMAGE=ghcr.io/the-teacher/rails-start.base:latest
          push: true
```

---

## ✅ Checklist before using

- [ ] Both workflow files are in `.github/workflows/`
- [ ] (for Docker Hub) Added DOCKER_HUB_USERNAME and DOCKER_HUB_TOKEN secrets
- [ ] Path to Dockerfile is correct: `docker/IMAGES/_Base.Dockerfile`
- [ ] IMAGE_NAME in both files matches your repositories
- [ ] (optional) Updated IMAGE_NAME according to your registries

---

## 🔄 Multi-Architecture process

Both workflows use:

1. **QEMU** - ARM64 emulation on Linux
2. **Docker Buildx** - native multi-platform builder
3. **Caching** - speed up repeated builds

Result: single image works on ARM64 and AMD64 identically! ✅
