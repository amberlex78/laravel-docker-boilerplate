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

## 🔐 Встановлення Авторизації (Laravel Breeze / Starter Kits)

Щоб отримати готову систему реєстрації та логіну з коробки:

1. Зайдіть у контейнер PHP:
   ```bash
   make bash
   ```
2. Встановіть Breeze та запустіть міграції (оберіть бажаний стек при встановленні, наприклад Blade або React):
   ```bash
   composer require laravel/breeze --dev
   php artisan breeze:install
   php artisan migrate
   exit
   ```
3. Зберіть фронтенд асети за допомогою Node.js контейнера:
   ```bash
   make npm cmd="install"
   make npm cmd="run dev"
   ```
   *(Vite сервер буде автоматично доступний на порту `5173` з підтримкою Hot Module Replacement).*

---

## 🛠 Довідник команд (Makefile)

Замість того, щоб вводити довгі команди `docker compose`, використовуйте `make`:

- `make install-laravel` - Встановити чистий Laravel у папку `src/` (та налаштувати права доступу).
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
