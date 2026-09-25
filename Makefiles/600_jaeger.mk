# =============================================================================
# Jaeger tracing commands
# =============================================================================

# Remove all Jaeger traces by dropping and recreating the storage volume
jaeger_clean:
	docker compose -f $(COMPOSE_FILE) stop jaeger
	docker compose -f $(COMPOSE_FILE) rm -f jaeger
	docker volume rm $$(docker volume ls -q | grep jaeger_data) 2>/dev/null || true
	docker compose -f $(COMPOSE_FILE) up -d jaeger

# Help for Jaeger commands
jaeger-help:
	@echo "=============================================================="
	@echo "Jaeger commands:"
	@echo "=============================================================="
	@echo "  make jaeger_clean  - Remove all traces (drop & recreate volume)"
	@echo "=============================================================="
