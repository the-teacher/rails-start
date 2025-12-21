nginx-shell:
	@echo ">>> Nginx shell access inside the container"
	docker compose -f $(COMPOSE_FILE) exec nginx /bin/sh