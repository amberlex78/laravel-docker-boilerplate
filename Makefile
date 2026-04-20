CURRENT_UID = $(shell id -u)
CURRENT_GID = $(shell id -g)

DOCKER_DEV  = docker compose -f docker-compose.yml -f docker-compose.dev.yml

PHP_RUN     = $(DOCKER_DEV) run --rm -it -u www-data app
PHP_EXEC    = $(DOCKER_DEV) exec -u www-data app


# ————————————————————————————— Settings
.DEFAULT_GOAL = help
.PHONY: help build install create-project up down restart shell logs


## ————————————————————————————— Targets
help: ## Показати цю довідку
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## ————————————————————————————— Install
install: ## Збірка та запуск контейнерів
	@$(DOCKER_DEV) down --remove-orphans
	@$(DOCKER_DEV) build --pull
	@$(DOCKER_DEV) up --detach
	@echo "\033[33mКонтейнери готові.\033[0m"

create-project: ## Створення проекту Laravel
	@$(DOCKER_DEV) run --rm -it app sh -c "\
		laravel new tmp_project && \
		cp -a tmp_project/. . && \
		rm -rf tmp_project && \
		chown -R $(CURRENT_UID):$(CURRENT_GID) ."
	@echo "\033[32mПроект успішно створено у папці src/\033[0m"


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

composer: ## Приклад: make composer c='require fruitcake/laravel-debugbar --dev'
	@$(PHP_EXEC) composer $(c)


##—————————————————————————————— Frontend (NPM)
npm-install: ## Встановити JS-залежності
	@$(PHP_EXEC) npm install

npm-build: ## Зібрати фронтенд для продакшну
	@$(PHP_EXEC) npm run build

npm-shell: ## Зайти в консоль з Node
	@$(PHP_EXEC) bash
