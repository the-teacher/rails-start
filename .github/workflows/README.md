# Docker Image Build Chain

Three workflows for automatic building and publishing Docker images: Base → Main → Media.

## 🔗 Build Chain

```
Base (linux/amd64, linux/arm64)
  ↓ workflow_run
Main (linux/amd64, linux/arm64)
  ↓ workflow_run
Media (linux/amd64, linux/arm64)
```

**On push to master/main:**

1. Base workflow runs when `_Base.Dockerfile` changes
2. If Base builds successfully → Main automatically triggers
3. If Main builds successfully → Media automatically triggers

Each workflow has a `check-*` job that verifies the upstream workflow completed successfully.

| Workflow                       | Trigger                          | What it does                            | Registry   |
| ------------------------------ | -------------------------------- | --------------------------------------- | ---------- |
| `docker-base-image.yml`        | Push/PR + manual                 | Base amd64, arm64                       | GHCR       |
| `docker-main-image.yml`        | workflow_run(Base) + push/manual | Main amd64, arm64                       | GHCR       |
| `docker-media-image.yml`       | workflow_run(Main) + push/manual | Media amd64, arm64                      | GHCR       |
| `docker-update-all-images.yml` | Manual only (sequential)         | Base → Main → Media (multiarch :latest) | Docker Hub |
| `clear-cache.yml`              | Manual only                      | Delete all GitHub Actions caches        | —          |

## 🏗️ Architectures

- `linux/amd64` — Intel/AMD 64-bit (desktops, servers)
- `linux/arm64` — ARM 64-bit (M1/M2 Mac, aarch64 servers)

## 🎛️ Flexible Base Image Selection

Main and Media workflows allow choosing upstream image source via `workflow_dispatch`:

- `ghcr` — `ghcr.io/the-teacher/rails-start.*:latest`
- `dockerhub` — `iamteacher/rails-start.*:latest`

Default: GHCR.

Dockerfiles use `ARG BASE_IMAGE` and `ARG MAIN_IMAGE` for flexibility.

## 📝 Local Build

```bash
cd docker/IMAGES

# Base (default Docker Hub)
make base-images-buildx-update

# Main with GHCR base
make main-images-buildx-push BASE_IMAGE_SOURCE=ghcr

# Media with GHCR main
make media-images-buildx-push MAIN_IMAGE_SOURCE=ghcr
```

## 🧪 Testing

```bash
# View workflow runs
# → GitHub Actions tab

# Check tags in GHCR
curl -s https://ghcr.io/v2/the-teacher/rails-start.base/tags/list | jq

# Download and test
docker pull ghcr.io/the-teacher/rails-start.media:latest
docker run --rm -it ghcr.io/the-teacher/rails-start.media:latest /bin/bash

# Check versions
docker run --rm ghcr.io/the-teacher/rails-start.media:latest ruby -v
docker run --rm ghcr.io/the-teacher/rails-start.media:latest node -v
docker run --rm ghcr.io/the-teacher/rails-start.media:latest ffmpeg -version
```

## 🔐 Secrets (for Docker Hub)

To enable Docker Hub publishing:

1. **Get token:** https://app.docker.com/accounts/iamteacher/settings/personal-access-tokens

   - Click "New Access Token"
   - Set type to "Read & Write"
   - Copy token immediately (won't show again)

2. **Add to GitHub:** https://github.com/the-teacher/rails-start/settings/secrets/actions
   - Click "New repository secret"
   - Add `DOCKER_HUB_USERNAME` = your Docker Hub username
   - Add `DOCKER_HUB_TOKEN` = the token you copied
   - ⚠️ Use token, not password!

GHCR uses `GITHUB_TOKEN` (built-in, no setup needed).

## 📋 Tags

Each workflow generates tags automatically:

- `branch` — branch name (master, main)
- `sha` — commit SHA
- `latest` — if default branch

Example:

```
ghcr.io/the-teacher/rails-start.base:master
ghcr.io/the-teacher/rails-start.base:master-abc1234
ghcr.io/the-teacher/rails-start.base:latest
```

## ✅ Verify Chain

On push to master:

1. GitHub Actions → select workflow (docker-base-image)
2. Check logs: did Base build successfully?
3. Verify Main workflow auto-triggered (workflow_run trigger)
4. Verify Media workflow auto-triggered after Main
5. If any stage fails — `check-*` job shows the problem

## 🐛 Troubleshooting

**Workflow not running:**

- Verify file paths match (`docker/IMAGES/_Base.Dockerfile`, etc.)
- `workflow_run` trigger only fires for successful upstream builds

**Docker pull media type error:**

- Provenance disabled (`provenance: false`) — this is correct

**Platform mismatch:**

- All workflows use same platforms: `linux/amd64,linux/arm64`
- Media uses `BASE_IMAGE` from Main; Main uses `BASE_IMAGE` from Base

## 💾 GitHub Actions Cache Management

### How Caching Works

Each build step uses `cache-from: type=gha` and `cache-to: type=gha,mode=max` to store and reuse Docker layers:

- **First build:** All layers are built and stored in cache
- **Subsequent builds (same Dockerfile):** Layers are reused from cache → much faster ✅
- **Cache age:** Automatic cleanup after 7 days of no access

### View Caches

Go to **Actions → Caches** in GitHub to see:
- Cache size
- Last accessed date
- Associated workflow/branch

### Clear All Caches (Manual)

If you notice old caches or want a fresh build:

1. GitHub Actions tab
2. Select **"Clear GitHub Actions Cache"** workflow
3. Click **"Run workflow"** → confirm
4. Monitor the run log to see how many caches were deleted

### Force Fresh Build

Option 1: Run `clear-cache.yml` first, then re-run your build workflow

Option 2: Modify Dockerfile slightly (GitHub detects file changes and skips cache)

## 📚 Files

- `.github/workflows/docker-*-image.yml` — GHCR workflows (automatic on push)
- `.github/workflows/docker-update-all-images.yml` — Docker Hub manual update (Base → Main → Media, multiarch :latest only)
- `docker/IMAGES/_Base.Dockerfile` — Base image
- `docker/IMAGES/_Main.Dockerfile` — Main image (ARG BASE_IMAGE)
- `docker/IMAGES/_Media.Dockerfile` — Media image (ARG BASE_IMAGE)
