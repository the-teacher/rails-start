# =============================================================================
# Rails Start - Fast Track to Rails Development
# https://github.com/the-teacher/rails-start
#
# Rails Start helps companies, entrepreneurs, and Rails learners get started quickly.
# Created by Ilya Zykin (https://github.com/the-teacher)
#
# ⭐ Support the project - leave your stars on GitHub and tell your colleagues!
# =============================================================================

# =============================================================================
# ENV Management Commands
# =============================================================================

# Quick setup for development
env-setup-development:
	@echo "Setting up environment files for development..."
	@mkdir -p ENV/local
	@if [ ! -f ENV/local/.env.development ]; then \
		cp ENV/examples/.env ENV/local/.env.development && \
		echo "✅ Created ENV/local/.env.development"; \
	else \
		echo "⚠️  ENV/local/.env.development already exists"; \
	fi
	@echo "🎉 Environment setup complete! You can now run 'make start'"

# Alias for development (backward compatibility)
env-setup: env-setup-development

# Test setup
env-setup-test:
	@echo "Setting up environment files for test..."
	@mkdir -p ENV/local
	@if [ ! -f ENV/local/.env.test ]; then \
		cp ENV/examples/.env ENV/local/.env.test && \
		echo "✅ Created ENV/local/.env.test"; \
	else \
		echo "⚠️  ENV/local/.env.test already exists"; \
	fi

# Production setup
env-setup-production:
	@echo "Setting up environment files for production..."
	@mkdir -p ENV/local
	@if [ ! -f ENV/local/.env.production ]; then \
		cp ENV/examples/.env ENV/local/.env.production && \
		echo "✅ Created ENV/local/.env.production"; \
		echo "⚠️  WARNING: Customize values for your production environment!"; \
		echo "📝 Edit ENV/local/.env.production before deployment"; \
	else \
		echo "⚠️  ENV/local/.env.production already exists"; \
	fi

# Clean local env files
env-clean:
	@echo "Removing local environment files..."
	@rm -f ENV/local/.env*
	@echo "✅ Local environment files removed"

# Validate env files exist
env-validate:
	@echo "Validating environment files..."
	@if [ ! -f ENV/local/.env.development ]; then \
		echo "❌ ENV/local/.env.development not found. Run 'make env-setup' first"; exit 1; \
	fi
	@echo "✅ Environment files validation passed"

# Show current env file status
env-status:
	@echo "Environment files status:"
	@echo "========================="
	@for file in ENV/local/.env.development ENV/local/.env.test ENV/local/.env.production; do \
		if [ -f "$$file" ]; then \
			echo "✅ $$file exists"; \
		else \
			echo "❌ $$file missing"; \
		fi \
	done

# Help for ENV commands
env-help:
	@echo "Environment Management Commands:"
	@echo "================================"
	@echo "  make env-setup-development - Setup development environment (.env.development)"
	@echo "  make env-setup-test        - Setup test environment (.env.test)"
	@echo "  make env-setup-production  - Setup production environment (.env.production)"
	@echo ""
	@echo "  make env-setup             - Alias for env-setup-development"
	@echo ""
	@echo "  make env-clean             - Remove all local env files"
	@echo "  make env-validate          - Validate env files exist"
	@echo "  make env-status            - Show status of env files"
	@echo "  make env-help              - Show this help"
	@echo ""
	@echo "File locations:"
	@echo "  ENV/examples/.env          - Base template for all environments"
	@echo "  ENV/local/.env.*           - Your actual env files (not in git)"
	@echo ""
	@echo "Usage:"
	@echo "  RAILS_ENV=development docker-compose up  # Uses .env.development"
	@echo "  RAILS_ENV=production docker-compose up   # Uses .env.production"
	@echo "  RAILS_ENV=test docker-compose up         # Uses .env.test"
