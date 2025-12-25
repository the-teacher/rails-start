<img src="./docs/images/rails-start-banner.jpg" alt="Rails Start" />

# Rails Start!

"Rails Start" is a starter kit for Ruby on Rails applications, designed to help developers quickly set up a new project with essential features and best practices.

This project is a perfect choice for:

- **Enterprises** looking to standardize their Rails application setup.
- **Freelancers and agencies** to kickstart client projects.
- **Online education platforms** to start teaching Ruby on Rails.
- **Individual developers** who want a solid foundation for their Rails applications.

## Requirements

- `Docker` and `Docker Compose` installed on your machine.
- `git` installed (usually comes pre-installed on MacOS and Linux).
- `make` utility installed (usually comes pre-installed on MacOS and Linux).
- `WSL2` (For Windows users) with a Linux distribution (like Ubuntu) is recommended.

## How to Use

<details>
<summary><strong>🪟 Windows Requirements (Click to expand)</strong></summary>

### Prerequisites for Windows Users

Before proceeding, Windows users need to set up WSL2:

1. **Install WSL2 and Ubuntu** (if not installed yet):

   Open `cmd` or `PowerShell` and run:

   ```powershell
   wsl --install
   wsl --set-default-version 2
   wsl --install -d Ubuntu
   ```

2. **Install make utility**:

   Run `WSL` and install `make`:

   ```bash
   wsl
   sudo apt-get install -y make
   ```

3. **Continue with the installation steps below** inside your WSL2 Ubuntu terminal.

</details>

### Installation Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/the-teacher/rails-start.git
   ```

2. Navigate to the project directory:

   ```bash
   cd rails-start
   ```

3. Start the application:
   ```bash
   make rails-start
   ```

That's it! Very simple!

Now visit: `http://localhost:3000` in your browser.

<img src="./docs/images/rails-start-2.png" alt="Rails Start Welcome Page" />

## The Idea

- `Docker` and `Docker Compose` for easy environment setup.
- `Makefiles` to simplify commands and automate tasks.
- `DevContainer` to make development environment consistent and easy to work with.
- `make rails-start` the only command you need to start your project.

## Docker Images

- [Docker Files](./docker/IMAGES/)

### Docker Hub

- [Base: Initial Software](https://hub.docker.com/r/iamteacher/rails-start.base/tags) | [Base.Dockerfile](./docker/IMAGES/_Base.Dockerfile)
- [Main: Ruby + NodeJS + Rails](https://hub.docker.com/r/iamteacher/rails-start.main/tags) | [Main.Dockerfile](./docker/IMAGES/_Main.Dockerfile)
- [Media: Media Processing Tools](https://hub.docker.com/r/iamteacher/rails-start.media/tags) | [Media.Dockerfile](./docker/IMAGES/_Media.Dockerfile)

### Github Container Registry

- [Base: Initial Software](https://github.com/the-teacher/rails-start/pkgs/container/rails-start.base) | [Base.Dockerfile](./docker/IMAGES/_Base.Dockerfile)
- [Main: Ruby + NodeJS + Rails](https://github.com/the-teacher/rails-start/pkgs/container/rails-start.main) | [Main.Dockerfile](./docker/IMAGES/_Main.Dockerfile)
- [Media: Media Processing Tools](https://github.com/the-teacher/rails-start/pkgs/container/rails-start.media) | [Media.Dockerfile](./docker/IMAGES/_Media.Dockerfile)

# License

[MIT License. 2023-2025. Ilya N. Zykin](./LICENSE.md)
