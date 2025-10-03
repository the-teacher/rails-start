# Project Management Commands

Simple reference for `Makefiles/100_Project.mk` commands in logical usage order.

## Available Commands

| Command                        | Description                                   |
| ------------------------------ | --------------------------------------------- |
| `make project-help`            | Show project management commands help         |
| `make build`                   | Build containers                              |
| `make rebuild`                 | Rebuild containers (no cache)                 |
| `make start`                   | Start all containers                          |
| `make up`                      | Start all containers (alias)                  |
| `make status`                  | Show running containers status                |
| `make shell`                   | Open shell in rails_app container             |
| `make root-shell`              | Open shell in rails_app container as root     |
| `make stop`                    | Stop all containers                           |
| `make down`                    | Stop all containers (alias)                   |
| `make project-setup-structure` | Create required project directories and files |
