# Laravel 13 Docker Boilerplate

Універсальний стартовий набір для швидкого розгортання проєктів на Laravel 13 за допомогою Docker. Налаштовано для комфортної локальної розробки (dev) та безпечного продакшену (prod).

## 🚀 Швидкий старт (Локальна розробка)

Цей репозиторій є "чистою" інфраструктурою. Сам код Laravel встановлюється всередину в процесі ініціалізації.

### 1. Клонування репозиторію
```bash
git clone git@github.com:amberlex78/dockerized-laravel.git
cd dockerized-laravel
```

### 2. Встановлення Laravel
Виконайте цю команду. Вона автоматично завантажить свіжий Laravel 13 у папку `src/` та налаштує правильні права доступу для Nginx та PHP-FPM.
```bash
make install-laravel
```

### 3. Запуск контейнерів
Запустіть середовище розробки:
```bash
make up-dev
```
Після завантаження ваш сайт буде доступний за адресою: [http://localhost:8000](http://localhost:8000).

### 4. Налаштування Бази Даних
У папці `src/` було автоматично створено файл `.env`. Відкрийте його і переконайтеся, що налаштування бази даних відповідають тим, що вказані в Docker:
```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

---

## 🔐 Встановлення Авторизації (Laravel Fortify)

Для налаштування бекенд-авторизації (логін, реєстрація, скидання пароля тощо):

1. Зайдіть у контейнер PHP:

   ```bash
   make bash
   ```
2. Встановіть Fortify та запустіть міграції:

   ```bash
   composer require laravel/fortify
   php artisan fortify:install
   php artisan migrate
   exit
   ```

---

## 🛠 Додаткові інструменти розробки

### Laravel Debugbar
Для зручного дебагу (перегляд запитів до БД, логів, рендерінгу) рекомендується встановити Laravel Debugbar:

1. Встановлення:

   ```bash
   make debugbar-install
   ```
2. Панель автоматично з'явиться внизу сторінки в режимі `APP_DEBUG=true`.

---

## 🤖 Інтеграція AI (Laravel Boost & MCP)

Laravel Boost — це MCP (Model Context Protocol) сервер, який дозволяє AI-агентам (Claude Code, Cursor, Windsurf тощо) краще розуміти ваш проект, переглядати маршрути, базу даних та виконувати Artisan команди.

1. **Встановлення Boost:**

   Виконайте команду для встановлення пакету та запуску інтерактивного інсталятора:
   ```bash
   make boost-install
   ```

2. **Підключення AI-агента:**

   Оскільки Laravel працює в Docker, ваш AI-агент на хості має звертатися до нього через `docker exec`.
   
   **Команда для MCP клієнта:**
   ```bash
   docker exec -i ${APP_NAME:-laravel}_app php artisan boost:mcp
   ```
   *(Замініть `laravel_app` на назву вашого контейнера, якщо ви змінили `APP_NAME`).*

   **Приклад для Claude Code:**
   ```bash
   claude mcp add laravel-boost --scope local -- docker exec -i ${APP_NAME:-laravel}_app php artisan boost:mcp
   ```

---

## 🛠 Довідник команд (Makefile)

Замість того, щоб вводити довгі команди `docker compose`, використовуйте `make`:

- `make install-laravel` - Встановити чистий Laravel у папку `src/` (та налаштувати права доступу).
- `make boost-install` - Встановити та налаштувати Laravel Boost (AI інтеграція).
- `make debugbar-install` - Встановити Laravel Debugbar (інструмент дебагу).
- `make up-dev` - Запустити середовище розробки (всі контейнери).
- `make stop` - Зупинити всі контейнери.
- `make logs` - Переглянути логи в реальному часі.
- `make bash` - Зайти в bash-термінал контейнера **PHP**.
- `make node-bash` - Зайти в термінал контейнера **Node.js**.
- `make artisan cmd="..."` - Запустити команду artisan (напр. `make artisan cmd="make:controller AuthController"`).
- `make npm cmd="..."` - Запустити команду npm (напр. `make npm cmd="run build"`).
- `make db-shell` - Зайти в термінал бази даних MariaDB.
- `make build-dev` / `make build-prod` - Перезібрати Docker-образи з нуля.

---

## 🌍 Продакшен середовище

Для деплою використовується окремий файл `docker-compose.prod.yml` та multi-stage збірка в Dockerfile. Код "зашивається" в образ PHP та Nginx, Xdebug вимикається, а OPcache вмикається. Для запуску оптимізацій Laravel автоматично викликається `php artisan optimize`.

```bash
# Запуск у продакшені
make up-prod
```
