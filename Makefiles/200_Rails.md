# Rails Development Commands

Simple reference for `Makefiles/200_Rails.mk` commands in logical usage order.

**Note**: These commands delegate to `__RailsApp__/Makefiles/200_Rails.mk` inside the container for maximum code reuse.

## Available Commands

| Command                    | Description                                   |
| -------------------------- | --------------------------------------------- |
| `make rails-help`          | Show Rails development commands help          |
| `make rails-setup`         | Full development setup (delegated)            |
| `make rails-bundle`        | Install development dependencies              |
| `make rails-db-create`     | Create development database                   |
| `make rails-db-migrate`    | Run development database migrations           |
| `make rails-db-seed`       | Seed development database                     |
| `make rails-server`        | Start Rails server (interactive mode)         |
| `make rails-server-daemon` | Start Rails server (daemon mode)              |
| `make rails-start`         | Full setup + start server in daemon mode      |
| `make rails-stop`          | Stop Rails development server                 |
| `make rails-console`       | Open development Rails console                |
| `make rails-log-tail`      | Tail development application log              |
| `make rails-logs`          | Tail development application log (alias)      |
| `make rails-log-clear`     | Clear development application log             |
| `make rails-bash`          | Access bash in development container          |
| `make rails-status`        | Show running processes inside Rails container |
