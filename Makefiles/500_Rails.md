# Rails Makefile Commands

Documentation for all make commands in `Makefiles/500_Rails.mk` (executed from project root).

## Main Commands

| Command            | Description                              |
| ------------------ | ---------------------------------------- |
| `make help`        | Show main help                           |
| `make rails-help`  | Show Rails development commands help     |
| `make rails-start` | Start Rails server with all dependencies |

## Rails Application Commands

### Setup and Dependencies

| Command             | Description               |
| ------------------- | ------------------------- |
| `make rails-bundle` | Install Ruby dependencies |

### Database Operations

| Command                 | Description             |
| ----------------------- | ----------------------- |
| `make rails-db-create`  | Create database         |
| `make rails-db-migrate` | Run database migrations |
| `make rails-db-seed`    | Seed the database       |

### Server Management

| Command            | Description                              |
| ------------------ | ---------------------------------------- |
| `make rails-start` | Start Rails server with all dependencies |

### Monitoring and Status

| Command             | Description                                   |
| ------------------- | --------------------------------------------- |
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
make rails-bundle                # Install dependencies
make rails-db-create             # Create database
make rails-db-migrate            # Run migrations
make rails-db-seed               # Seed database
```

### Development Workflow

```bash
make rails-start                 # Start Rails with full setup
make rails-status                # Check running processes
# ... development work ...
make stop                        # Stop containers when done
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

### Startup Sequence

1. **Container startup** - `make up`
2. **Bundle install** - `make rails-bundle`
3. **Database creation** - `make rails-db-create`
4. **Database migration** - `make rails-db-migrate`
5. **Rails server start** - `bundle exec rails s -b 0.0.0.0 -p 3000`

## Docker Integration

### Container Execution

All commands execute inside the `rails_app` container using:

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
  - `make rails-bundle` (dependencies)
  - `make rails-db-create` (database)
  - `make rails-db-migrate` (schema)

## Features

- **Containerized Rails development** - all operations in Docker
- **Automatic dependency management** - handles bundle install
- **Database lifecycle** - creation, migration, seeding
- **Process monitoring** - view running processes in container
- **Complete startup sequence** - one command for full setup
- **Host accessibility** - server accessible from host machine

## Architecture

- **Docker Compose based** - uses existing container infrastructure
- **Service isolation** - Rails runs in dedicated container
- **Volume mounted development** - code changes reflected immediately
- **Network accessible** - server binds to all interfaces
- **Development optimized** - fast iteration and testing

## Integration Points

### With Other Makefiles

- Uses `make up` from `400_Project.mk`
- Uses `make stop` from `400_Project.mk`
- Complements container management commands

### With Rails Application

- Standard Rails commands (`rails db:create`, `rails s`, etc.)
- Bundle management (`bundle install`)
- Development server configuration
