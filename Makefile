.DEFAULT_GOAL := help

NO_COLOR=\033[0m
OK_COLOR=\033[34;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

.PHONY: help up down restart logs clean build test run-model test-model

help: ## Show available targets
	@echo "\033[1m\nTargets List:$(NO_COLOR)\n"
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

up: ## Start development environment
	@echo "$(OK_COLOR)Starting development environment...$(NO_COLOR)"
	docker compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 5

down: ## Stop development environment
	@echo "$(OK_COLOR)Stopping development environment...$(NO_COLOR)"
	docker compose down

restart:
	@echo "$(OK_COLOR)Restarting development environment...$(NO_COLOR)"
	docker compose restart

logs: ## Show development environment logs
	@echo "$(OK_COLOR)Showing development environment logs...$(NO_COLOR)"
	docker compose logs -f

clean: ## Clean dbt artifacts
	@echo "$(OK_COLOR)Cleaning dbt artifacts...$(NO_COLOR)"
	uv run dbt clean

run: ## Build dbt models
	@echo "$(OK_COLOR)Building dbt models...$(NO_COLOR)"
	uv run dbt run

test: ## Run dbt tests
	@echo "$(OK_COLOR)Running dbt tests...$(NO_COLOR)"
	uv run dbt test
