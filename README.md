# Laravel Docker Starter

Чистий та оптимізований шаблон для розробки на Laravel 13+ з Docker, Vite та автоматичною синхронізацією прав доступу.

## Швидкий старт

### 1. Підготовка інфраструктури
Створить файл `.env` з вашими UID/GID та збере образи:
```bash
make init
```

### 2. Створення проекту
Запустить інтерактивний інсталятор Laravel (`laravel new`). Виберіть Starter Kit (Inertia/Vue), тестування тощо:
```bash
make create-project
```
*Під час встановлення на питання про запуск `npm install` та `npm run build` можна відповідати **no**, оскільки `make` зробить це автоматично.*

### 3. Запуск для розробки
Запустить PHP, MySQL, Nginx та Vite у фоновому режимі:
```bash
make dev
```
Додаток буде доступний на: [http://localhost:8000](http://localhost:8000)

---

## Основні команди Makefile

- `make init` — Перший запуск (налаштування UID/GID та збірка).
- `make dev` — Запуск проекту та Vite.
- `make stop` — Зупинити всі контейнери.
- `make artisan c="command"` — Виконати команду Artisan (напр. `make artisan c="migrate"`).
- `make composer c="require package"` — Встановити PHP-пакет.
- `make npm-install` — Встановити JS-залежності.
- `make shell` — Зайти в консоль PHP-контейнера.

## Особливості
- **Синхронізація прав**: Файли в папці `src/` завжди належать вам, а не root.
- **Vite HMR**: Hot Module Replacement працює "з коробки" через Docker.
- **Wayfinder**: Автоматична генерація типів для маршрутів (якщо використовується цей пакет).
- **Multi-stage Build**: Dockerfile оптимізований для Dev та Production.
