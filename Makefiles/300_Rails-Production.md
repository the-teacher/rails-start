# Rails Production Makefile Commands

Documentation for all make commands in `Makefiles/300_Rails-Production.mk` (executed from project root).

## Main Commands

| Command                       | Description                         |
| ----------------------------- | ----------------------------------- |
| `make help`                   | Show main help                      |
| `make rails-production-help`  | Show production Rails commands help |
| `make rails-production-start` | Full production startup sequence    |

## Production Setup Commands

### Dependencies and Assets

| Command                        | Description                      |
| ------------------------------ | -------------------------------- |
| `make rails-production-bundle` | Install production dependencies  |
| `make rails-production-assets` | Precompile assets for production |
| `make rails-production-clean`  | Clean production assets          |

### Database Operations

| Command                            | Description                                         |
| ---------------------------------- | --------------------------------------------------- |
| `make rails-production-db-create`  | Create production database                          |
| `make rails-production-db-migrate` | Migrate production database                         |
| `make rails-production-db-seed`    | Seed production database                            |
| `make rails-production-db-setup`   | Setup production database (create + migrate + seed) |

## Production Server Management

### Server Operations

| Command                        | Description                           |
| ------------------------------ | ------------------------------------- |
| `make rails-production-server` | Start Rails server in production mode |
| `make rails-production-start`  | Full production startup sequence      |

### Container Lifecycle

| Command                         | Description                                  |
| ------------------------------- | -------------------------------------------- |
| `make rails-production-up`      | Start production containers in detached mode |
| `make rails-production-down`    | Stop production containers                   |
| `make rails-production-restart` | Restart production containers                |

## Production Access Commands

### Console and Shell

| Command                         | Description                         |
| ------------------------------- | ----------------------------------- |
| `make rails-production-console` | Open production Rails console       |
| `make rails-production-bash`    | Access bash in production RAILS_ENV |

### Monitoring

| Command                      | Description          |
| ---------------------------- | -------------------- |
| `make rails-production-logs` | View production logs |

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
make rails-production-bundle     # Install production dependencies
make rails-production-assets     # Precompile assets
make rails-production-db-setup   # Setup database
make rails-production-server     # Start server
```

### Container Management

```bash
make rails-production-up         # Start containers in background
make rails-production-logs       # Monitor logs
make rails-production-restart    # Restart if needed
make rails-production-down       # Stop containers
```

### Production Maintenance

```bash
make rails-production-console    # Access Rails console
make rails-production-bash       # Access system shell
make rails-production-clean      # Clean compiled assets
```

### Database Management

```bash
make rails-production-db-create  # Create database
make rails-production-db-migrate # Run migrations
make rails-production-db-seed    # Populate with data
```

## Production Startup Sequence

### Full Sequence (`rails-production-start`)

1. **Bundle install** - `rails-production-bundle`
2. **Asset precompilation** - `rails-production-assets`
3. **Database setup** - `rails-production-db-setup`
   - Create database
   - Run migrations
   - Seed data
4. **Server start** - `rails-production-server`

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

All commands execute in the `rails_app` container:

```bash
docker compose -f $(COMPOSE_FILE) exec rails_app bash -c "command"
```

### Environment Handling

Production-specific environment:

```bash
RAILS_ENV=production docker compose -f $(COMPOSE_FILE) command
```

## Features

- **Production-ready deployment** - optimized for production use
- **Asset precompilation** - optimized static assets
- **Production dependencies** - minimal dependency set
- **Database lifecycle management** - complete database setup
- **Container orchestration** - Docker Compose integration
- **Log monitoring** - production log access
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
