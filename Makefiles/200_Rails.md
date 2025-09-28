# Rails Development Makefile Commands

Documentation for all make commands in `Makefiles/200_Rails.mk` (executed from project root).

**Note**: These commands delegate to `__RailsApp__/Makefiles/200_Rails.mk` inside the container for maximum code reuse.

## Main Commands

| Command            | Description                              |
| ------------------ | ---------------------------------------- |
| `make help`        | Show main help                           |
| `make rails-help`  | Show Rails development commands help     |
| `make rails-start` | Full setup + start server in daemon mode |

## Rails Application Commands

### Setup and Dependencies

| Command             | Description                        |
| ------------------- | ---------------------------------- |
| `make rails-setup`  | Full development setup (delegated) |
| `make rails-bundle` | Install development dependencies   |

### Database Operations

| Command                 | Description                         |
| ----------------------- | ----------------------------------- |
| `make rails-db-create`  | Create development database         |
| `make rails-db-migrate` | Run development database migrations |
| `make rails-db-seed`    | Seed development database           |

### Server Management

| Command                    | Description                              |
| -------------------------- | ---------------------------------------- |
| `make rails-server`        | Start Rails server (interactive mode)    |
| `make rails-server-daemon` | Start Rails server (daemon mode)         |
| `make rails-start`         | Full setup + start server in daemon mode |
| `make rails-stop`          | Stop Rails development server            |

### Console & Logs

| Command                | Description                              |
| ---------------------- | ---------------------------------------- |
| `make rails-console`   | Open development Rails console           |
| `make rails-log-tail`  | Tail development application log         |
| `make rails-logs`      | Tail development application log (alias) |
| `make rails-log-clear` | Clear development application log        |

### Docker Container Management

| Command             | Description                                   |
| ------------------- | --------------------------------------------- |
| `make rails-bash`   | Access bash in development container          |
| `make rails-status` | Show running processes inside Rails container |

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

### Quick Start

```bash
make rails-start                 # Complete Rails setup and start
```

### Step-by-Step Setup

```bash
make up                          # Start containers first
make rails-setup                 # Full development setup (delegated)
# OR manually:
make rails-bundle                # Install dependencies
make rails-db-create             # Create database
make rails-db-migrate            # Run migrations
```

### Development Workflow

```bash
make rails-start                 # Start Rails with full setup (daemon mode)
make rails-status                # Check running processes
make rails-logs                  # View application logs
# ... development work ...
make rails-stop                  # Stop Rails server
make stop                        # Stop containers when done
```

### Server Management

```bash
make rails-server                # Interactive mode (blocks terminal, shows logs)
# OR
make rails-server-daemon         # Daemon mode (background, use rails-logs to view)
make rails-stop                  # Stop server
```

### Database Management

```bash
make rails-db-create             # Create database
make rails-db-migrate            # Run new migrations
make rails-db-seed               # Populate with seed data
```

### Monitoring

```bash
make rails-status                # Check Rails container processes
```

## Rails Server Configuration

### Server Settings

- **Bind address**: `0.0.0.0` (accessible from host)
- **Port**: `3000` (standard Rails development port)
- **Environment**: Development mode (default)
- **Server modes**: Interactive (blocking) or Daemon (background)

### Startup Sequence (rails-start)

1. **Container startup** - `make up`
2. **Bundle install** - delegated to container `make bundle`
3. **Database creation** - delegated to container `make db-create`
4. **Database migration** - delegated to container `make db-migrate`
5. **Rails server start** - daemon mode with pidfile

## Docker Integration

### Container Execution

Most commands delegate to `__RailsApp__/Makefiles/200_Rails.mk` inside the container using:

```bash
docker compose -f $(COMPOSE_FILE) exec rails_app make command
```

Direct commands use:

```bash
docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "command"
```

### Volume Mounting

- Application code is mounted into container
- Changes on host are reflected in container
- Database data persists between container restarts

## Dependencies

### Required Services

- **Docker Compose** must be running
- **rails_app container** must be available
- **Database service** (as defined in docker-compose.yml)

### Command Dependencies

- `rails-start` depends on:
  - `make up` (container startup)
  - Delegated commands inside container:
    - `make bundle` (dependencies)
    - `make db-create` (database)
    - `make db-migrate` (schema)

## Features

- **Containerized Rails development** - all operations in Docker
- **Command delegation** - reuses container-level Makefiles
- **Automatic dependency management** - handles bundle install
- **Database lifecycle** - creation, migration, seeding
- **Server modes** - interactive and daemon modes
- **Log management** - tail, view, and clear application logs
- **Process monitoring** - view running processes in container
- **Complete startup sequence** - one command for full setup
- **Host accessibility** - server accessible from host machine

## Architecture

- **Command delegation pattern** - maximizes code reuse
- **Docker Compose based** - uses existing container infrastructure
- **Service isolation** - Rails runs in dedicated container
- **Volume mounted development** - code changes reflected immediately
- **Network accessible** - server binds to all interfaces
- **Development optimized** - fast iteration and testing
- **Unified command interface** - consistent with production commands

## Integration Points

### With Other Makefiles

- Uses `make up` from `100_Project.mk`
- Uses `make stop` from `100_Project.mk`
- Complements container management commands

### With Rails Application

- Delegates to `__RailsApp__/Makefiles/200_Rails.mk` for main logic
- Standard Rails commands executed inside container
- Bundle management via container-level commands
- Development server configuration with Docker networking
- Log management through container-level commands
