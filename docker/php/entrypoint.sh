#!/bin/sh
set -e

# If there's a composer.json but vendors are missing, install them (useful in dev volume mounts)
if [ -f "composer.json" ] && [ ! -d "vendor" ]; then
    echo "Installing composer dependencies..."
    composer install --prefer-dist
fi

# Run migrations if .env exists
if [ -f ".env" ] && [ "$APP_ENV" != "production" ]; then
    echo "Running migrations..."
    # php artisan migrate --force || true
fi

# Optimize caches if in production
if [ "$APP_ENV" = "production" ] && [ -f "artisan" ]; then
    echo "Optimizing application..."
    php artisan optimize
fi

# Set permissions for local dev if needed
if [ "$APP_ENV" != "production" ] && [ -d "storage" ]; then
    chmod -R 777 storage bootstrap/cache || true
fi

exec "$@"
