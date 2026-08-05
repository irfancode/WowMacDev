.PHONY: help build up down logs shell test clean deploy

help: ## Show this help message
	@echo "MacAdmin - Available Commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build all Docker images
	docker-compose build

up: ## Start all services in detached mode
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## View logs from all services
	docker-compose logs -f

shell-backend: ## Open shell in backend container
	docker-compose exec backend /bin/bash

shell-frontend: ## Open shell in frontend container
	docker-compose exec frontend /bin/sh

test: ## Run all tests
	docker-compose exec backend pytest

clean: ## Remove all containers and images
	docker-compose down -v --rmi all

deploy-prod: ## Deploy to production (requires domain and email)
	@if [ -z "$(domain)" ] || [ -z "$(email)" ]; then \
		echo "Usage: make deploy-prod domain=your-domain.com email=admin@example.com"; \
		exit 1; \
	fi
	./scripts/deploy.sh $(domain) $(email)

update: ## Pull latest images and restart
	docker-compose pull
	docker-compose up -d

status: ## Show status of all containers
	docker-compose ps

brew-update: ## Update Homebrew packages inside container
	docker-compose exec backend python -c "import subprocess; subprocess.run(['brew', 'update'])"
