# Rails Production Makefile Commands

Documentation for all make commands in `Makefiles/300_Rails-Production.mk` (executed from project root).

**Note**: These commands delegate to `__RailsApp__/Makefiles/300_Production.mk` inside the container for maximum code reuse.

## Main Commands

| Command                       | Description                              |
| ----------------------------- | ---------------------------------------- |
| `make help`                   | Show main help                           |
| `make rails-production-help`  | Show production Rails commands help      |
| `make rails-production-start` | Full setup + start server in daemon mode |

## Production Setup Commands

### Setup and Dependencies

| Command                              | Description                         |
| ------------------------------------ | ----------------------------------- |
| `make rails-production-setup`        | Full production setup (delegated)   |
| `make rails-production-bundle`       | Install production dependencies     |
| `make rails-production-bundle-reset` | Reset bundle config for development |

### Assets

| Command                              | Description                      |
| ------------------------------------ | -------------------------------- |
| `make rails-production-assets`       | Precompile assets for production |
| `make rails-production-precompile`   | Precompile assets (alias)        |
| `make rails-production-assets-clean` | Clean production assets          |

### Database Operations

| Command                             | Description                                         |
| ----------------------------------- | --------------------------------------------------- |
| `make rails-production-db-create`   | Create production database                          |
| `make rails-production-db-migrate`  | Migrate production database                         |
| `make rails-production-db-seed`     | Seed production database                            |
| `make rails-production-db-setup`    | Setup production database (create + migrate + seed) |
| `make rails-production-db-reset`    | Reset production database (with confirmation)       |
| `make rails-production-db-rollback` | Rollback production database migration              |

## Production Server Management

### Server Operations

| Command                               | Description                              |
| ------------------------------------- | ---------------------------------------- |
| `make rails-production-server`        | Start Rails server (interactive mode)    |
| `make rails-production-server-daemon` | Start Rails server (daemon mode)         |
| `make rails-production-start`         | Full setup + start server in daemon mode |
| `make rails-production-stop`          | Stop Rails production server             |

### Console & Logs

| Command                           | Description                             |
| --------------------------------- | --------------------------------------- |
| `make rails-production-console`   | Open production Rails console           |
| `make rails-production-log-tail`  | Tail production application log         |
| `make rails-production-logs`      | Tail production application log (alias) |
| `make rails-production-log-clear` | Clear production application log        |

### Docker Container Management

| Command                             | Description                            |
| ----------------------------------- | -------------------------------------- |
| `make rails-production-up`          | Start production containers (detached) |
| `make rails-production-down`        | Stop production containers             |
| `make rails-production-restart`     | Restart production containers          |
| `make rails-production-docker-logs` | View Docker container logs             |
| `make rails-production-bash`        | Access bash in production container    |

### Combined Workflows

| Command                            | Description                                    |
| ---------------------------------- | ---------------------------------------------- |
| `make rails-production-full-start` | Complete startup (containers + setup + server) |

## Configuration

### Variables

| Variable       | Default Value                 | Description                               |
| -------------- | ----------------------------- | ----------------------------------------- |
| `COMPOSE_FILE` | `./docker/docker-compose.yml` | Path to Docker Compose file               |
| `RAILS_ENV`    | `production`                  | Rails environment for production commands |

### Production Server Settings

| Setting      | Value        | Description                  |
| ------------ | ------------ | ---------------------------- |
| Environment  | `production` | Rails production environment |
| Bind Address | `0.0.0.0`    | Accessible from host         |
| Port         | `3000`       | Standard Rails port          |

## Usage Examples

### Complete Production Setup

```bash
make rails-production-start      # Full production startup sequence
```

### Step-by-Step Production Setup

```bash
make rails-production-setup      # Full production setup (delegated)
# OR manually:
make rails-production-bundle     # Install production dependencies
make rails-production-assets     # Precompile assets
make rails-production-db-setup   # Setup database
make rails-production-server     # Start server (interactive)
# OR
make rails-production-server-daemon # Start server (daemon mode)
```

### Container Management

```bash
make rails-production-up         # Start containers in background
make rails-production-logs       # Monitor application logs
make rails-production-docker-logs # Monitor Docker container logs
make rails-production-restart    # Restart if needed
make rails-production-down       # Stop containers
```

### Server Management

```bash
make rails-production-server     # Interactive mode (blocks terminal, shows logs)
# OR
make rails-production-server-daemon # Daemon mode (background, use logs to view)
make rails-production-stop       # Stop server
```

### Production Maintenance

```bash
make rails-production-console      # Access Rails console
make rails-production-bash         # Access system shell
make rails-production-assets-clean # Clean compiled assets
make rails-production-bundle-reset # Reset bundle for development
```

### Database Management

```bash
make rails-production-db-create  # Create database
make rails-production-db-migrate # Run migrations
make rails-production-db-seed    # Populate with data
```

## Production Startup Sequence

### Full Sequence (`rails-production-start`)

1. **Bundle install** - delegated to container `make production-bundle`
2. **Database creation** - delegated to container `make production-db-create`
3. **Database migration** - delegated to container `make production-db-migrate`
4. **Asset cleanup** - delegated to container `make production-assets-clean`
5. **Asset precompilation** - delegated to container `make production-assets-precompile`
6. **Server start** - daemon mode with pidfile

### Database Setup (`rails-production-db-setup`)

1. **Create database** - `rails-production-db-create`
2. **Run migrations** - `rails-production-db-migrate`
3. **Seed database** - `rails-production-db-seed`

## Production Environment

### Bundle Configuration

- **Excludes development gems** - `--without development test`
- **Production optimized** - only necessary dependencies
- **Faster deployment** - smaller bundle size

### Asset Management

- **Precompiled assets** - optimized for production
- **Asset cleaning** - removes old compiled assets
- **Performance optimized** - minified and compressed

### Environment Variables

- **RAILS_ENV=production** - set for container operations
- **Production database** - uses production database configuration
- **Production logging** - production log levels and formats

## Docker Integration

### Container Operations

Most commands delegate to `__RailsApp__/Makefiles/300_Production.mk` inside the container:

```bash
docker compose -f $(COMPOSE_FILE) exec rails_app make production-command
```

Direct commands use:

```bash
docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "command"
```

### Environment Handling

Production-specific environment for container operations:

```bash
RAILS_ENV=production docker compose -f $(COMPOSE_FILE) command
```

## Features

- **Command delegation pattern** - maximizes code reuse with container-level Makefiles
- **Production-ready deployment** - optimized for production use
- **Asset precompilation** - optimized static assets with cleanup
- **Production dependencies** - minimal dependency set with reset capability
- **Database lifecycle management** - complete database setup with rollback support
- **Server modes** - interactive and daemon modes for different use cases
- **Container orchestration** - Docker Compose integration
- **Log monitoring** - both application and Docker container logs
- **Console access** - Rails console in production mode
- **System access** - bash shell with production environment

## Security Considerations

- **Minimal dependencies** - reduces attack surface
- **Production environment** - security-focused configuration
- **Container isolation** - isolated production environment
- **Asset optimization** - compiled and minified assets

## Performance Features

- **Precompiled assets** - faster asset serving
- **Production gems only** - smaller memory footprint
- **Optimized database** - production database configuration
- **Container efficiency** - production-tuned containers

## Integration Points

### With Development Environment

- **Separate from development** - isolated production setup
- **Database independence** - separate production database
- **Asset isolation** - separate asset compilation

### With Docker Infrastructure

- **Docker Compose based** - uses existing container setup
- **Environment-aware** - respects RAILS_ENV settings
- **Service integration** - works with all container services
- **Command delegation** - delegates to `__RailsApp__/Makefiles/300_Production.mk`
- **Unified architecture** - consistent with development commands pattern
