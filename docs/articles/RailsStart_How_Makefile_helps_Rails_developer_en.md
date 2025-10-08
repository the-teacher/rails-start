# [RailsStart](https://github.com/the-teacher/rails-start): How Makefile Helps Rails Developers

<img src="../images/rails-start-banner-2.webp" alt="Rails Start" />

## Introduction

Several years ago, I needed a quick playground for launching **Rails** applications for new projects and experiments. I also create video lectures and masterclasses on **Rails**, and I needed a project where my program attendees could practice their skills.

This is how the **[RailsStart](https://github.com/the-teacher/rails-start)** project was created, which allows launching **Rails** applications quickly, almost instantly.

**The main goal of the project** - to enable running **Rails** on any operating system with literally one command.

In this article, I will tell you about the importance of `Makefile` for implementing my project. Its architecture is based on the elegant use of `Makefile` - a tool that transforms complex **Docker** and **Rails** commands into simple and understandable calls.

## What are Make and Makefile?

**Make** is a build automation utility that manages the compilation and build process of software. It uses a file called **Makefile**, which describes the rules and dependencies for building a project.

**`Makefile`** is a text file containing a set of instructions for the **Make** utility.

`Makefile` is commonly used in **C/C++** projects for compilation, in system administration for task automation, in **DevOps** for deployment management, and in various projects for standardizing development commands.

In my project, **Make** and `Makefile` are of great importance. These tools allow me to automate project setup and **Rails** application launch.

Thanks to the simplicity of **Make**, launching a **Rails** application in my project is done simply, elegantly, and with literally one command.

## What do you need to run [Rails Start](https://github.com/the-teacher/rails-start)?

To run [Rails Start](https://github.com/the-teacher/rails-start), you need only three tools familiar to any developer:

- **Git** - to get the project from **GitHub**
- **Make** - to run the automatic installation process
- **Docker** - to run the application in a container

If these tools are available on your operating system, you can consider that the **Rails** application will be installed in less than 5 minutes.

## Why do I use **Make** instead of **Ruby** scripts or **Rake**?

The first version of the project relied on automation and launch scripts based on **Ruby** technologies.

However, to make the process universal for host machines where **Ruby** might not be installed, I switched to using the popular **Make**, which can be used both on the host machine and in a container.

> ⚠️ **Important Note:**
>
> Rails Start performs automatic preparation and setup of everything needed to run a Rails application, and does this using the **Make** utility, which automates many actions and processes in a simple and efficient way.
>
> **Make** is chosen as the simplest and most widespread tool. **Ruby** scripts or **Rake** commands simply cannot be used at this stage because they may not exist yet. The **Make** utility is already installed on many systems or can be installed with minimal effort.

**Advantages of Make over Ruby scripts:**

- **Universality** - **Make** is available on virtually all **Unix** systems
- **Independence** - does not require **Ruby** installation on the host system
- **Simplicity** - clear syntax for command automation
- **Standardness** - a familiar tool for developers

## Two-Level `Makefiles` Architecture

The key feature of [RailsStart](https://github.com/the-teacher/rails-start) lies in the **two-level `Makefiles` system**:

The [RailsStart](https://github.com/the-teacher/rails-start) project uses 2 levels of `Makefiles`. One level is designed for use at the host system level (the computer you work on), the second level of `Makefiles` is designed for use inside **Docker** containers.

I try to adhere to unified and consistent command names so that identical commands can be run at different levels using approximately identical **Make** commands.

### 1. Host Level (Project)

**Location:** `/Makefiles/`

This level is responsible for managing **Docker** containers and orchestrating the entire project. Host-level commands automatically delegate execution to the appropriate containers, providing a uniform interface:

```makefile
# Simple launch of the entire project
make rails-start

# Container management
make start    # Start containers
make stop     # Stop containers
make status   # Container status

# Delegating Rails commands to container
make rails-console     # Open Rails console
make rails-db-migrate  # Run migrations
make rails-server      # Start Rails server
```

**Main functions:**

- **Docker Compose** management
- Project environment setup
- Command delegation to containers
- File structure organization
- Unified interface for all operations

### 2. Container Level

**Location:** `/__RailsApp__/Makefiles/`

This level contains commands that are executed directly inside the **Rails** container. Commands have similar names to host commands but are executed in the container context:

```makefile
# Commands inside container
make setup      # Rails application setup
make console    # Rails console
make db-migrate # Database migrations
make server     # Start Rails server
make bundle     # Install gems
```

**Main functions:**

- **Rails**-specific commands
- Database management
- Dependency management (**bundler**)
- Generators and testing
- Direct execution in **Rails** application context

## Modular Structure

Each level is organized with sets of Makefile files with specific purposes for better structure and maintenance:

```
rails-start/
├── Makefiles/                   # Host level
│   ├── 100_Project.mk           # Docker and project management
│   ├── 200_Rails.mk             # Rails command delegation
│   ├── 300_Rails-Production.mk  # Production environment
│   └── 400_env.mk               # Environment variables management
│
└── __RailsApp__/
    └── Makefiles/               # Container level
        ├── 100_Project.mk       # Common container commands
        ├── 200_Rails.mk         # Rails development
        └── 300_Production.mk    # Production commands
```

### Host level:

- `100_Project.mk` - Docker and project management
- `200_Rails.mk` - Rails command delegation
- `300_Rails-Production.mk` - Production environment
- `400_env.mk` - Environment variables management

### Container level:

- `100_Project.mk` - Common container commands
- `200_Rails.mk` - Rails development
- `300_Production.mk` - Production commands

## Advantages of This Approach

### 1. **Command Uniformity at Different Levels**

Thanks to unified command names, developers can use similar commands both on the host and inside the container:

```bash
# On host
make rails-console     # Delegates to container
make rails-db-migrate  # Delegates to container

# Inside container (after make rails-bash)
make console           # Executes directly
make db-migrate        # Executes directly
```

### 2. **Ease of Use**

```bash
# Instead of complex command:
docker compose -f ./docker/docker-compose.yml exec rails_app bundle exec rails db:migrate

# Simply:
make rails-db-migrate
```

### 3. **Command Unification Across Operating Systems**

Whether you work on **macOS**, **Linux**, or **Windows** (via **WSL**), the commands remain the same.

### 4. **Self-Documentation**

```bash
make help                   # General help
make rails-help             # Rails commands
make project-help           # Project management
make rails-production-help  # Production commands
```

### 5. **Transparent Command Delegation**

Host commands are automatically delegated to containers, maintaining interface uniformity:

```makefile
# On host (Makefiles/200_Rails.mk)
rails-console:
	docker compose -f $(COMPOSE_FILE) exec rails_app make console

rails-db-migrate:
	docker compose -f $(COMPOSE_FILE) exec rails_app make db-migrate

# In container (__RailsApp__/Makefiles/200_Rails.mk)
console:
	bundle exec rails console

db-migrate:
	bundle exec rails db:migrate
```

This architecture allows developers not to think about where exactly the command is executed - the system automatically chooses the right context.

## Practical Examples

### Quick project start:

```bash
git clone https://github.com/the-teacher/rails-start.git
cd rails-start
make rails-start  # All ready!
```

### Daily development:

```bash
make rails-console     # Open Rails console
make rails-db-migrate  # Run migrations
make rails-logs        # View logs
make rails-status      # Check processes
```

### Database operations:

```bash
make rails-db-create   # Create database
make rails-db-seed     # Seed with data
make rails-db-reset    # Full reset (with warning)
```

### Generators and testing:

```bash
make rails-bash                             # Enter container
make generate-model name=User               # Create model
make generate-controller name=Users         # Create controller
make test                                   # Run tests
```

## Conclusion

`Makefile` is not commonly found in **Rails** projects, and this technology is not very widespread for working with **Rails** applications. However, the [RailsStart](https://github.com/the-teacher/rails-start) project shows an example of an effective and elegant solution for running **Rails** on any operating system.

`Makefile` in the [RailsStart](https://github.com/the-teacher/rails-start) project doesn't just simplify commands - it creates a **unified management interface** for the entire **Rails** application lifecycle.

The two-level architecture provides clear separation of responsibilities between infrastructure management (host) and application development (container).

This solution is especially valuable for:

- **Development teams** - workflow unification
- **New project members** - quick understanding of available commands
- **DevOps practices** - deployment standardization
- **Rails learning** - focus on development rather than environment setup

[RailsStart](https://github.com/the-teacher/rails-start) proves that a properly organized `Makefile` can transform a complex **Docker** + **Rails** environment into a simple and intuitive development tool.

---

## Glossary

**Host machine** - a physical or virtual computer on which Docker and other software runs. In the context of the article - your working machine (macOS, Linux, Windows).

**Container** - an isolated application runtime environment created using containerization technology. Contains the application and all its dependencies.

**Docker** - a platform for developing, delivering, and running applications in containers. [docker.com](https://www.docker.com/)

**Docker Compose** - a tool for defining and running multi-container Docker applications. [docs.docker.com/compose](https://docs.docker.com/compose/)

**Make** - a build automation utility for managing compilation and command execution. [gnu.org/software/make](https://www.gnu.org/software/make/)

**Makefile** - a configuration file for the Make utility, containing rules and commands for task automation.

**Rails (Ruby on Rails)** - a web framework for the Ruby programming language. [rubyonrails.org](https://rubyonrails.org/)

**Git** - a distributed version control system. [git-scm.com](https://git-scm.com/)

**WSL (Windows Subsystem for Linux)** - a Windows subsystem for Linux that allows running a Linux environment on Windows. [docs.microsoft.com/windows/wsl](https://docs.microsoft.com/en-us/windows/wsl/)
