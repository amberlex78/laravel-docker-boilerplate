export USER_ID := $(shell id -u)
export GROUP_ID := $(shell id -g)

DOCKER_DEV  = docker compose -f docker-compose.yml -f docker-compose.dev.yml
DOCKER_PROD = docker compose -f docker-compose.yml -f docker-compose.prod.yml

PHP_RUN     = $(DOCKER_DEV) run --rm -u www-data app
PHP_EXEC    = $(DOCKER_DEV) exec -u www-data app


# ————————————————————————————— Settings
.DEFAULT_GOAL = help
.PHONY: help init create-project build up down restart shell logs \
        composer artisan key-generate optimize tinker \
        migrate migrate-fresh db-seed db-shell \
        npm-install npm-build npm-dev \
        fix-permissions clean

## ————————————————————————————— Targets
help: ## Показати цю довідку
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## ————————————————————————————— Install & Setup
init: ## Збірка та запуск контейнерів
	@$(DOCKER_DEV) down --remove-orphans
	@$(DOCKER_DEV) build --pull
	@$(DOCKER_DEV) up --detach
	@$(MAKE) help --no-print-directory
	@echo "\033[33mКонтейнери готові.\033[0m"

create-project: ## Створення проекту Laravel (інтерактивно)
	@$(DOCKER_DEV) run --rm -u root app chown -R www-data:www-data /var/www/html
	@$(DOCKER_DEV) run --rm -it -u www-data app sh -c "\
		laravel new tmp_project && \
		cp -a tmp_project/. . && \
		rm -rf tmp_project"
	@$(MAKE) fix-permissions
	@echo "\033[32mLaravel успішно встановлено!\033[0m"

fix-permissions: ## Виправити права на папку src (sudo)
	@sudo chown -R $(USER_ID):$(GROUP_ID) .
	@$(DOCKER_DEV) exec app chown -R www-data:www-data storage bootstrap/cache

## ————————————————————————————— Docker Operations
build: ## Зібрати образи
	@$(DOCKER_DEV) build

up: ## Підняти проект у Dev режимі
	@$(DOCKER_DEV) up --detach

down: ## Зупинити проект
	@$(DOCKER_DEV) down --remove-orphans

restart: down up ## Перезапуск проекту

shell: ## Зайти в консоль PHP контейнера
	@$(PHP_EXEC) bash

logs: ## Перегляд логів у реальному часі
	@$(DOCKER_DEV) logs -f

## ————————————————————————————— Laravel Tools
composer: ## Запуск composer. Приклад: make composer c='require ...'
	@$(PHP_EXEC) composer $(c)

artisan: ## Запуск artisan. Приклад: make artisan c='migrate'
	@$(PHP_EXEC) php artisan $(c)

tinker: ## Зайти в Laravel Tinker
	@$(PHP_EXEC) php artisan tinker

key-generate: ## Згенерувати APP_KEY
	@$(PHP_EXEC) php artisan key:generate

optimize: ## Повне очищення та оптимізація Laravel
	@$(PHP_EXEC) php artisan optimize:clear
	@$(PHP_EXEC) php artisan optimize

## ————————————————————————————— Databases
migrate: ## Запустити міграції
	@$(PHP_EXEC) php artisan migrate

migrate-fresh: ## Перестворити базу даних
	@$(PHP_EXEC) php artisan migrate:fresh --seed

db-seed: ## Запустити сідери
	@$(PHP_EXEC) php artisan db:seed

db-shell: ## Зайти в консоль MariaDB
	@$(DOCKER_DEV) exec db mariadb -u $${DB_USERNAME:-laravel} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-laravel}

## ————————————————————————————— Frontend
npm-install: ## Встановити JS-залежності
	@$(PHP_EXEC) npm install

npm-dev: ## Запустити Vite у режимі розробки
	@$(PHP_EXEC) npm run dev

npm-build: ## Зібрати фронтенд для Prod
	@$(PHP_EXEC) npm run build

## ————————————————————————————— Cleaning
clean: ## Повна очистка: видалення вендорів, логів та образів
	@$(DOCKER_DEV) down --rmi local --volumes --remove-orphans
	@rm -rf src/vendor src/node_modules src/storage/logs/*.log
