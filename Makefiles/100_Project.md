# Project Makefile Commands

Documentation for all make commands in `Makefiles/100_Project.mk` (executed from project root).

## Main Commands

| Command             | Description                           |
| ------------------- | ------------------------------------- |
| `make help`         | Show main help                        |
| `make project-help` | Show project management commands help |
| `make start`        | Start all containers                  |
| `make stop`         | Stop all containers                   |

## Container Lifecycle Commands

### Start/Stop Operations

| Command      | Description                  |
| ------------ | ---------------------------- |
| `make start` | Start all containers         |
| `make up`    | Start all containers (alias) |
| `make stop`  | Stop all containers          |
| `make down`  | Stop all containers (alias)  |

### Build Operations

| Command        | Description                   |
| -------------- | ----------------------------- |
| `make build`   | Build or rebuild containers   |
| `make rebuild` | Rebuild containers (no cache) |

### Status and Information

| Command       | Description                    |
| ------------- | ------------------------------ |
| `make status` | Show running containers status |

## Container Access Commands

### Shell Access

| Command           | Description                                    |
| ----------------- | ---------------------------------------------- |
| `make shell`      | Open shell in rails_app container              |
| `make root-shell` | Open shell in rails_app container as root user |

## Setup Commands

### Project Structure

| Command                        | Description                                   |
| ------------------------------ | --------------------------------------------- |
| `make project-setup-structure` | Create required project directories and files |

## Configuration

### Variables

| Variable       | Default Value                 | Description                 |
| -------------- | ----------------------------- | --------------------------- |
| `COMPOSE_FILE` | `./docker/docker-compose.yml` | Path to Docker Compose file |

### Container Services

| Service     | Description                      |
| ----------- | -------------------------------- |
| `rails_app` | Main Rails application container |

## Usage Examples

### Basic Operations

```bash
make start                       # Start all containers
make status                      # Check container status
make shell                       # Access Rails container
make stop                        # Stop all containers
```

### Development Workflow

```bash
make start                       # Start development environment
make shell                       # Access container for development
# ... development work ...
make stop                        # Stop when done
```

### Container Management

```bash
make build                       # Build containers
make rebuild                     # Rebuild from scratch
make status                      # Check running status
```

### Troubleshooting

```bash
make root-shell                  # Access as root for system operations
make rebuild                     # Rebuild if issues persist
make status                      # Verify container health
```

## Docker Compose Integration

### File Structure

- Uses `./docker/docker-compose.yml` as compose file
- Manages multi-container Rails application setup
- Provides consistent development environment

### Container Features

- **Persistent volumes** for development files
- **Port mapping** for web access
- **Service networking** between containers
- **Environment isolation** from host system

## Project Structure Setup

### Created Directories

- `tmp/` - Temporary files directory

### Created Files

- `tmp/.bash_history` - Bash history for container sessions

## Command Aliases

| Primary Command | Alias       | Description      |
| --------------- | ----------- | ---------------- |
| `make start`    | `make up`   | Start containers |
| `make stop`     | `make down` | Stop containers  |

## Features

- **Docker Compose integration** - manages multi-container applications
- **Automatic setup** - creates required project structure
- **Shell access** - both regular and root user access
- **Status monitoring** - formatted container status display
- **Build management** - handles container building and rebuilding
- **Service isolation** - containers run in isolated network

## Architecture

- **Multi-container setup** using Docker Compose
- **Volume mounting** for development workflow
- **Network isolation** between services
- **Persistent storage** for application data
- **Development-friendly** configuration
