nginx-build:
	docker-compose -f $(COMPOSE_FILE) build nginx

nginx-up:
	docker-compose -f $(COMPOSE_FILE) up -d nginx

nginx-down:
	docker-compose -f $(COMPOSE_FILE) down nginx

nginx-start:
	make nginx-up

nginx-stop:
	make nginx-down

nginx-logs:
	docker-compose -f $(COMPOSE_FILE) logs -f nginx

nginx-shell:
	docker-compose -f $(COMPOSE_FILE) exec nginx /bin/sh