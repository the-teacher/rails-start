# Rails App Makefile Commands

Documentation for all make commands in `__RailsApp__/Makefiles` directory (executed inside container).

## Main Commands

| Command                 | Description                |
| ----------------------- | -------------------------- |
| `make help`             | Show main help             |
| `make setup`            | Complete application setup |
| `make start`            | Start Rails server         |
| `make production-start` | Start production server    |

## Rails Commands (100_Rails.mk)

### Setup and Server

| Command            | Description                                                |
| ------------------ | ---------------------------------------------------------- |
| `make setup`       | Setup application (bundle, db:create, db:migrate, db:seed) |
| `make server`      | Start Rails server via puma                                |
| `make start`       | Start Rails server (alias for server)                      |
| `make rails-start` | Start Rails server (alias for server)                      |
| `make stop`        | Graceful stop Rails server                                 |

### Console and Logs

| Command          | Description                   |
| ---------------- | ----------------------------- |
| `make console`   | Open Rails console            |
| `make log-tail`  | Tail application logs         |
| `make logs`      | Tail application logs (alias) |
| `make log-clear` | Clear application logs        |

### Help

| Command                    | Description                      |
| -------------------------- | -------------------------------- |
| `make rails-help`          | Show Rails commands help         |
| `make rails-internal-help` | Show Rails commands help (alias) |

## Project Commands (200_Project.mk)

### Dependencies

| Command               | Description                            |
| --------------------- | -------------------------------------- |
| `make bundle`         | Install Ruby dependencies (all groups) |
| `make update-bundler` | Update bundler and dependencies        |

### Database

| Command            | Description                                  |
| ------------------ | -------------------------------------------- |
| `make db-create`   | Create database                              |
| `make db-migrate`  | Run database migrations                      |
| `make migrate`     | Run database migrations (alias)              |
| `make db-seed`     | Seed database                                |
| `make seed`        | Seed database (alias)                        |
| `make db-drop`     | Drop database (with confirmation)            |
| `make db-reset`    | Reset database (drop, create, migrate, seed) |
| `make db-rollback` | Rollback last migration                      |

### Generators

| Command                                  | Description                 |
| ---------------------------------------- | --------------------------- |
| `make generate`                          | Show generators help        |
| `make generate-model name=User`          | Generate model              |
| `make model name=User`                   | Generate model (alias)      |
| `make generate-controller name=Users`    | Generate controller         |
| `make controller name=Users`             | Generate controller (alias) |
| `make generate-migration name=add_field` | Generate migration          |
| `make migration name=add_field`          | Generate migration (alias)  |

### Testing

| Command            | Description      |
| ------------------ | ---------------- |
| `make test`        | Run all tests    |
| `make test-system` | Run system tests |

### Assets

| Command             | Description           |
| ------------------- | --------------------- |
| `make assets-clean` | Clean compiled assets |

### Utilities

| Command       | Description                    |
| ------------- | ------------------------------ |
| `make routes` | Show all routes                |
| `make tasks`  | Show all available Rails tasks |

### Code Quality

| Command            | Description                |
| ------------------ | -------------------------- |
| `make brakeman`    | Run security analysis      |
| `make rubocop`     | Run code style analysis    |
| `make rubocop-fix` | Auto-fix code style issues |

### Maintenance

| Command      | Description               |
| ------------ | ------------------------- |
| `make clean` | Clean assets, logs, cache |

### Information

| Command           | Description                      |
| ----------------- | -------------------------------- |
| `make env-check`  | Check versions and configuration |
| `make status`     | Show running processes           |
| `make disk-usage` | Show disk usage information      |
| `make network`    | Show network configuration       |

### Help

| Command                      | Description                        |
| ---------------------------- | ---------------------------------- |
| `make project-help`          | Show project commands help         |
| `make project-internal-help` | Show project commands help (alias) |

## Production Commands (300_Production.mk)

### Setup

| Command                        | Description                           |
| ------------------------------ | ------------------------------------- |
| `make production-setup`        | Complete production environment setup |
| `make production-bundle`       | Install production dependencies       |
| `make production-bundle-reset` | Reset bundle config for dev mode      |

### Database

| Command                       | Description                                   |
| ----------------------------- | --------------------------------------------- |
| `make production-db-create`   | Create production database                    |
| `make production-db-migrate`  | Run production database migrations            |
| `make production-db-seed`     | Seed production database                      |
| `make production-db-reset`    | Reset production database (with confirmation) |
| `make production-db-rollback` | Rollback production database migration        |

### Server

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `make production-server` | Start Rails production server         |
| `make production-start`  | Start Rails production server (alias) |
| `make production-stop`   | Stop Rails production server          |

### Console

| Command                   | Description                   |
| ------------------------- | ----------------------------- |
| `make production-console` | Open Rails production console |

### Assets

| Command                             | Description               |
| ----------------------------------- | ------------------------- |
| `make production-assets-precompile` | Precompile assets         |
| `make production-precompile`        | Precompile assets (alias) |
| `make production-assets-clean`      | Clean production assets   |

### Logs

| Command                     | Description                  |
| --------------------------- | ---------------------------- |
| `make production-log-tail`  | Tail production logs         |
| `make production-logs`      | Tail production logs (alias) |
| `make production-log-clear` | Clear production logs        |

### Help

| Command                | Description                   |
| ---------------------- | ----------------------------- |
| `make production-help` | Show production commands help |

## Usage Examples

### Quick Development Start

```bash
make setup      # Setup application
make start      # Start server
```

### Database Work

```bash
make model name=User              # Create User model
make migration name=add_email     # Create migration
make migrate                      # Run migrations
make seed                         # Seed database
```

### Production Launch

```bash
make production-start             # Start production server
make production-stop              # Stop production server
make production-bundle-reset      # Return to dev mode
```

### Code Quality

```bash
make test                         # Run tests
make rubocop                      # Check code style
make brakeman                     # Check security
```
