#!/bin/sh
set -e

# If there's a composer.json but vendors are missing, install them (useful in dev volume mounts)
if [ -f "composer.json" ] && [ ! -d "vendor" ]; then
    echo "Installing composer dependencies..."
    composer install --prefer-dist
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
