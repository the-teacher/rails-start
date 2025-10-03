# Rails Production Commands

Simple reference for `Makefiles/300_Rails-Production.mk` commands in logical usage order.

**Note**: These commands delegate to `__RailsApp__/Makefiles/300_Production.mk` inside the container for maximum code reuse.

## Available Commands

| Command                               | Description                                         |
| ------------------------------------- | --------------------------------------------------- |
| `make rails-production-help`          | Show production Rails commands help                 |
| `make rails-production-setup`         | Full production setup (delegated)                   |
| `make rails-production-bundle`        | Install production dependencies                     |
| `make rails-production-bundle-reset`  | Reset bundle config for development                 |
| `make rails-production-up`            | Start production containers (detached)              |
| `make rails-production-db-create`     | Create production database                          |
| `make rails-production-db-migrate`    | Migrate production database                         |
| `make rails-production-db-seed`       | Seed production database                            |
| `make rails-production-db-setup`      | Setup production database (create + migrate + seed) |
| `make rails-production-db-reset`      | Reset production database (with confirmation)       |
| `make rails-production-db-rollback`   | Rollback production database migration              |
| `make rails-production-assets`        | Precompile assets for production                    |
| `make rails-production-precompile`    | Precompile assets (alias)                           |
| `make rails-production-assets-clean`  | Clean production assets                             |
| `make rails-production-server`        | Start Rails server (interactive mode)               |
| `make rails-production-server-daemon` | Start Rails server (daemon mode)                    |
| `make rails-production-start`         | Full setup + start server in daemon mode            |
| `make rails-production-stop`          | Stop Rails production server                        |
| `make rails-production-console`       | Open production Rails console                       |
| `make rails-production-log-tail`      | Tail production application log                     |
| `make rails-production-logs`          | Tail production application log (alias)             |
| `make rails-production-log-clear`     | Clear production application log                    |
| `make rails-production-docker-logs`   | View Docker container logs                          |
| `make rails-production-bash`          | Access bash in production container                 |
| `make rails-production-down`          | Stop production containers                          |
| `make rails-production-restart`       | Restart production containers                       |
| `make rails-production-full-start`    | Complete startup (containers + setup + server)      |
