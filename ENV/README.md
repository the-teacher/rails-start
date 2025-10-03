# ENV Configuration Guide

## Why ENV Files?

Your Rails app needs different settings for **development**, **test**, and **production**:

- Different database passwords
- Different hostnames
- Different secret keys
- Different admin credentials

## How It Works

1. **One template** (`ENV/examples/.env`) → **Copy to environment files**
2. **Docker automatically picks** the right file based on `RAILS_ENV`
3. **Your secrets stay local** (never committed to git)

## Quick Setup

```bash
# 1. Create development config
make env-setup-development

# 2. Edit with your values
vim ENV/local/.env.development

# 3. Start project
make start
```

## What to Change

Edit `ENV/local/.env.development` and customize:

- `DATABASE_PASSWORD` - your database password
- `ADMIN_EMAIL` - your admin email
- `ADMIN_PASSWORD` - your admin password
- `RAILS_HOST` - your domain (localhost:3000 for dev)

## Commands

```bash
make env-setup-development    # Setup dev environment
make env-setup-production     # Setup production environment
make env-status              # Check which files exist
```

## File Structure

```
ENV/
├── examples/.env           # Template (in git)
└── local/                  # Your configs (NOT in git)
    ├── .env.development
    ├── .env.test
    └── .env.production
```

---

**TL;DR**: `make env-setup-development` → edit file → `make start` 🚀
