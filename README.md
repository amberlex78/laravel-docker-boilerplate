# Laravel Docker Starter

Чистий та оптимізований шаблон для розробки на Laravel 13+ з Docker, Vite та автоматичною синхронізацією прав доступу.

## Швидкий старт

### 1. Збірка та запуск контейнерів
Запустіть команду для підготовки та першого запуску інфраструктури (ця команда збере образи та підніме контейнери у фоні):
```bash
make install
```

### 2. Створення проекту
Запустіть інтерактивний інсталятор Laravel (`laravel new`). Виберіть Starter Kit (Inertia/Vue), тестування тощо:
```bash
make create-project
```
* Під час встановлення на питання про запуск `npm install` та `npm run build` можна відповідати **no**, оскільки для цього є окремі команди у `Makefile`. 
* Також на питання про запуск міграцій (**Would you like to run migrations?**) відповідайте **No**, оскільки базу треба налаштувати після копіювання файлів.

### 3. База даних
У `src/.env` пропишіть параметри бази даних:
```bash
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```
Після цього перезапустіть контейнери:
```bash
make restart
```

Запустіть міграції та seeders:
```bash
make migrate
make db-seed
```


### 4. Запуск для розробки
Якщо ви зупиняли контейнери, для подальшої роботи використовуйте команду:
```bash
make up
```
Додаток буде доступний на: [http://localhost:8000](http://localhost:8000)
Для Vite HMR підготовлено порт `5173`.

---

## Основні команди Makefile

- `make init` — Повна збірка та запуск (виконувати при першому запуску).
- `make create-project` — Створення нового проекту Laravel (інтерактивно).
- `make fix-permissions` — Виправити права доступу на логи та кеш (якщо вони стали root).
- `make up` — Підняти контейнери проекту у фоновому режимі.
- `make down` — Зупинити та видалити контейнери.
- `make restart` — Перезапустити контейнери.
- `make shell` — Зайти в консоль PHP-контейнера.
- `make artisan c="command"` — Виконати команду Artisan (напр. `make artisan c="make:model Post"`).
- `make migrate` — Запустити міграції бази даних.
- `make migrate-fresh` — Перестворити базу даних (drop all tables & migrate).
- `make db-seed` — Запустити Database Seeders.
- `make db-shell` — Зайти в консоль MariaDB (SQL-клієнт).
- `make composer c="require package"` — Встановити PHP-пакет.
- `make npm-install` — Встановити JS-залежності.
- `make npm-build` — Зібрати фронтенд.
