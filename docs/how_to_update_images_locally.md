# How to Update Docker Images Locally

Use this when you updated the Ruby version (`.ruby-version`) or changed any Dockerfile.

## Steps

**1. Stop containers and remove the old image:**

```bash
make stop
docker rmi iamteacher/rails-start.main:latest
```

**2. Build a new image locally:**

Apple Silicon (arm64):

```bash
cd docker/IMAGES
make main-image-arm64-build
docker tag iamteacher/rails-start.main:arm64 iamteacher/rails-start.main:latest
```

Intel (amd64):

```bash
cd docker/IMAGES
make main-image-amd64-build
docker tag iamteacher/rails-start.main:amd64 iamteacher/rails-start.main:latest
```

**3. Start the project:**

```bash
cd ../..
docker compose -f ./docker/docker-compose.yml up -d --pull never
docker compose -f ./docker/docker-compose.yml exec rails make bundle
docker compose -f ./docker/docker-compose.yml exec rails make db-create
```

> **Why `--pull never`?** Without it, Docker Compose tries to pull the image from Docker Hub (even if a local image with that name exists).

> **Note:** Ruby is compiled from source via rbenv during the build — it takes several minutes.
