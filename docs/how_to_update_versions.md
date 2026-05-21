# How to Update Versions

## Ruby

| Where to check                                   | File to edit                                          |
| ------------------------------------------------ | ----------------------------------------------------- |
| https://www.ruby-lang.org/en/downloads/releases/ | `__RailsApp__/.ruby-version`                          |
|                                                  | `docker/IMAGES/_Main.Dockerfile` → `ARG RUBY_VERSION` |

Both files must have the same version. After updating — rebuild the image locally (see `how_to_update_images_locally.md`).

---

## RubyGems

| Where to check                                     | File to edit                                                 |
| -------------------------------------------------- | ------------------------------------------------------------ |
| https://rubygems.org/gems/rubygems-update/versions | `docker/IMAGES/_Main.Dockerfile` → `ARG DEFAULT_GEM_VERSION` |

After updating — rebuild the image.

---

## Bundler

| Where to check                             | File to edit                                              |
| ------------------------------------------ | --------------------------------------------------------- |
| https://rubygems.org/gems/bundler/versions | `__RailsApp__/Gemfile.lock` → `BUNDLED WITH` (last lines) |

After updating `Gemfile.lock`, run inside the container:

```bash
docker compose -f ./docker/docker-compose.yml exec rails gem install bundler -v X.X.X
docker compose -f ./docker/docker-compose.yml exec rails make bundle
```

---

## Rails

| Where to check                           | File to edit                                     |
| ---------------------------------------- | ------------------------------------------------ |
| https://rubygems.org/gems/rails/versions | `__RailsApp__/Gemfile` → `gem "rails", "~> X.X"` |

After updating `Gemfile`, run:

```bash
docker compose -f ./docker/docker-compose.yml exec rails make bundle
docker compose -f ./docker/docker-compose.yml exec rails make db-migrate
```

---

## Node.js

| Where to check                 | File to edit                                          |
| ------------------------------ | ----------------------------------------------------- |
| https://nodejs.org/en/download | `docker/IMAGES/_Main.Dockerfile` → `ARG NODE_VERSION` |

Node.js is installed via **nvm** for the `rails` user. The `PATH` in the Dockerfile points to the versioned nvm binary directory and is updated automatically on rebuild.

After updating `ARG NODE_VERSION` — rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails node --version
```

> When updating Node.js, also check if **npm** and **nvm** versions need updating (see sections below).

---

## npm

| Where to check                    | File to edit                                         |
| --------------------------------- | ---------------------------------------------------- |
| https://www.npmjs.com/package/npm | `docker/IMAGES/_Main.Dockerfile` → `ARG NPM_VERSION` |

npm is upgraded globally via nvm after Node.js installation. Update `ARG NPM_VERSION` and rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails npm --version
```

---

## nvm

| Where to check                         | File to edit                                         |
| -------------------------------------- | ---------------------------------------------------- |
| https://github.com/nvm-sh/nvm/releases | `docker/IMAGES/_Main.Dockerfile` → `ARG NVM_VERSION` |

nvm is installed via the official install script using the version specified in `ARG NVM_VERSION`. After updating — rebuild the image.

To verify after rebuild:

```bash
docker compose -f ./docker/docker-compose.yml exec rails bash -c '. ~/.nvm/nvm.sh && nvm --version'
```

---

## Summary table

| Package  | Version location                                   | Files to edit                                                         |
| -------- | -------------------------------------------------- | --------------------------------------------------------------------- |
| Ruby     | https://www.ruby-lang.org/en/downloads/releases/   | `__RailsApp__/.ruby-version`, `_Main.Dockerfile` → `ARG RUBY_VERSION` |
| RubyGems | https://rubygems.org/gems/rubygems-update/versions | `_Main.Dockerfile` → `ARG DEFAULT_GEM_VERSION`                        |
| Bundler  | https://rubygems.org/gems/bundler/versions         | `__RailsApp__/Gemfile.lock` → `BUNDLED WITH`                          |
| Rails    | https://rubygems.org/gems/rails/versions           | `__RailsApp__/Gemfile`                                                |
| Node.js  | https://nodejs.org/en/download                     | `_Main.Dockerfile` → `ARG NODE_VERSION`                               |
| npm      | https://www.npmjs.com/package/npm                  | `_Main.Dockerfile` → `ARG NPM_VERSION`                                |
| nvm      | https://github.com/nvm-sh/nvm/releases             | `_Main.Dockerfile` → `ARG NVM_VERSION`                                |

> After any change to `_Main.Dockerfile` — rebuild the image locally (see `how_to_update_images_locally.md`).
