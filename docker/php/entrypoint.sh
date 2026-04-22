#!/bin/sh
set -e

# Fix permissions for storage and cache if they exist
if [ -d "storage" ]; then
    echo "Checking permissions for storage and cache..."
    chown -R www-data:www-data storage bootstrap/cache
    chmod -R 775 storage bootstrap/cache
fi

# Ensure PHP-FPM socket directory is writable
if [ -d "/var/run/php-fpm" ]; then
    chown www-data:www-data /var/run/php-fpm
fi

# If there's a composer.json but vendors are missing, install them (useful in dev volume mounts)
if [ -f "composer.json" ] && [ ! -d "vendor" ]; then
    echo "Installing composer dependencies..."
    composer install --prefer-dist --no-interaction
fi

# Create .env if it doesn't exist
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

# Generate key if it's missing in .env
if [ -f ".env" ] && [ -f "artisan" ]; then
    if ! grep -q "APP_KEY=base64:" .env || [ -z "$(grep "APP_KEY=base64:" .env | cut -d '=' -f2)" ]; then
        echo "Generating application key..."
        php artisan key:generate --force
    fi
fi

# Run migrations if .env exists (only in dev/local)
if [ -f ".env" ] && [ "$APP_ENV" = "local" ]; then
    echo "Running migrations..."
    # php artisan migrate --force || true
fi

# Optimize caches if in production
if [ "$APP_ENV" = "production" ] && [ -f "artisan" ]; then
    echo "Optimizing application for production..."
    php artisan optimize
fi

exec "$@"
