.PHONY: help install-laravel up-dev build-dev stop logs bash artisan db-shell

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

help:
	@echo "Available commands:"
	@echo "  make install-laravel - Встановити новий Laravel проект (якщо src порожній)"
	@echo "  make up-dev          - Запустити середовище розробки"
	@echo "  make stop            - Зупинити всі контейнери"
	@echo "  make build-dev       - Перезібрати образи для dev"
	@echo "  make up-prod         - Запустити продакшен середовище"
	@echo "  make build-prod      - Перезібрати образи для prod"
	@echo "  make bash            - Зайти в контейнер PHP"
	@echo "  make node-bash       - Зайти в контейнер Node.js (для фронтенду)"
	@echo "  make npm cmd=...     - Запустити команду npm (напр. make npm cmd=install)"
	@echo "  make artisan cmd=... - Запустити команду artisan (напр. make artisan cmd=migrate)"
	@echo "  make db-shell        - Зайти в контейнер бази даних"

install-laravel:
	mkdir -p src
	docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm app sh -c "composer create-project --prefer-dist laravel/laravel tmp_laravel && cp -a tmp_laravel/. . && rm -rf tmp_laravel"
	sudo chown -R $$(id -u):$$(id -g) src/
	sudo chmod -R a+rX src/
	@echo "Laravel встановлено в src/. Для встановлення базового набору (Auth тощо) зайдіть в bash і запустіть відповідні команди."

up-dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

build-dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build

up-prod:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

build-prod:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build

stop:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.prod.yml down

logs:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f

bash:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec app /bin/bash

node-bash:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec node /bin/sh

npm:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec node npm $(cmd)

artisan:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec app php artisan $(cmd)

db-shell:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec db mariadb -u$${DB_USERNAME:-laravel} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-laravel}
