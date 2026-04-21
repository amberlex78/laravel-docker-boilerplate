export USER_ID := $(shell id -u)
export GROUP_ID := $(shell id -g)

DOCKER_DEV  = docker compose -f docker-compose.yml -f docker-compose.dev.yml

PHP_RUN     = $(DOCKER_DEV) run --rm -it -u www-data app
PHP_EXEC    = $(DOCKER_DEV) exec -u www-data app


# ————————————————————————————— Settings
.DEFAULT_GOAL = help
.PHONY: help init create-project build up down restart shell logs db-shell \
        artisan key-generate cache-clear migrate-fresh migrate db-seed composer \
        npm-install npm-build npm-shell fix-permissions


## ————————————————————————————— Targets
help: ## Показати цю довідку
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## ————————————————————————————— Install
init: ## Збірка та запуск контейнерів
	@$(DOCKER_DEV) down --remove-orphans
	@$(DOCKER_DEV) build --pull
	@$(DOCKER_DEV) up --detach
	@$(MAKE) --no-print-directory
	@echo "\033[33mКонтейнери готові.\033[0m"

fix-permissions: ## Виправити права на логи та сховище (sudo)
	@sudo chown -R $$(id -u):$$(id -g) docker/nginx/logs
	@sudo chown -R $$(id -u):$$(id -g) src/storage src/bootstrap/cache

create-project: ## Створення проекту Laravel
	@$(DOCKER_DEV) run --rm -it app sh -c "\
		laravel new tmp_project && \
		cp -a tmp_project/. . && \
		rm -rf tmp_project && \
		chown -R $$(id -u):$$(id -g) ."


## ————————————————————————————— Docker
build: ## Зібрати образи
	@$(DOCKER_DEV) build

up: ## Підняти проект
	@$(DOCKER_DEV) up --detach

down: ## Зупинити та видалити контейнери
	@$(DOCKER_DEV) down --remove-orphans

restart: down up ## Перезапуск

shell: ## Зайти в консоль PHP контейнера
	@$(PHP_EXEC) bash


## ————————————————————————————— Binaries
artisan: ## Приклад: make artisan c='migrate'
	@$(PHP_EXEC) php artisan $(c)

key-generate: ## Згенерувати APP_KEY
	@$(PHP_EXEC) php artisan key:generate

cache-clear: ## Очистити всі кеші Laravel
	@$(PHP_EXEC) php artisan optimize:clear

migrate-fresh: ## Drop all tables and re-run all migrations
	@$(PHP_EXEC) php artisan migrate:fresh

migrate: ## Запустити міграції бази даних
	@$(PHP_EXEC) php artisan migrate

db-seed: ## Run all database seeders
	@$(PHP_EXEC) php artisan db:seed

db-shell: ## Зайти в консоль бази даних
	@$(DOCKER_DEV) exec db mariadb -u $${DB_USERNAME:-laravel} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-laravel}

composer: ## Приклад: make composer c='require fruitcake/laravel-debugbar --dev'
	@$(PHP_EXEC) composer $(c)


##—————————————————————————————— Frontend (NPM)
npm-install: ## Встановити JS-залежності
	@$(PHP_EXEC) npm install

npm-build: ## Зібрати фронтенд для продакшну
	@$(PHP_EXEC) npm run build

npm-shell: ## Зайти в консоль з Node
	@$(PHP_EXEC) bash
