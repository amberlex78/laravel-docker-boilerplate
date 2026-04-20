# —————————————————————————————————————————————————————————————— Variables
# APP_NAME береться з .env або за замовчуванням 'laravel'
APP_NAME = $(shell grep APP_NAME .env | cut -d '=' -f2 || echo laravel)

DOCKER_COMP = docker compose

# Використовуємо два файли для розробки
DOCKER_DEV  = $(DOCKER_COMP) -f docker-compose.yml -f docker-compose.dev.yml

# Контейнери
# -it обов'язковий для інтерактивних запитань інсталятора
PHP_RUN     = $(DOCKER_DEV) run --rm -it app
PHP_EXEC    = $(DOCKER_DEV) exec app

# Бінарні файли всередині контейнера
COMPOSER    = $(PHP_EXEC) composer
ARTISAN     = $(PHP_EXEC) php artisan


# —————————————————————————————————————————————————————————————— Settings
.DEFAULT_GOAL = help
.PHONY: help build install create-project up down restart shell logs


## ————————————————————————————————————————————————————————————————————— Targets
help: ## Показати цю довідку
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## ————————————————————————————————————————————————————————————————————— Install
install: ## Початкова підготовка: збірка та запуск порожніх контейнерів
	@$(DOCKER_DEV) down --remove-orphans
	@$(DOCKER_DEV) build --pull
	@$(DOCKER_DEV) up --detach
	@echo "\033[33mКонтейнери готові. Тепер запускай: make create-project\033[0m"

create-project: ## Створення проекту Laravel (Starter Kit, Pest/PHPUnit тощо)
	@$(PHP_RUN) sh -c "\
		laravel new tmp_project && \
		cp -a tmp_project/. . && \
		rm -rf tmp_project && \
		chown -R $$(id -u):$$(id -g) ."
	@echo "\033[32mПроект успішно створено у папці src/\033[0m"


## ————————————————————————————————————————————————————————————————————— Docker
build: ## Зібрати образи (особливо після змін у Dockerfile)
	@$(DOCKER_DEV) build

up: ## Підняти проект
	@$(DOCKER_DEV) up --detach

down: ## Зупинити та видалити контейнери
	@$(DOCKER_DEV) down --remove-orphans

restart: down up ## Перезапуск

shell: ## Зайти в консоль PHP контейнера
	@$(PHP_EXEC) bash


## ————————————————————————————————————————————————————————————————————— Binaries
artisan: ## Приклад: make artisan c='migrate'
	@$(ARTISAN) $(c)

composer: ## Приклад: make composer c='require fruitcake/laravel-debugbar --dev'
	@$(COMPOSER) $(c)

## —————————————————————————————————————————————————————————————————————