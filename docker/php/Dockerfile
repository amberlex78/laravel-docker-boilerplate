# Base Stage
FROM php:8.5-fpm-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    icu-dev \
    oniguruma-dev \
    linux-headers \
    bash

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl

# Install Composer
COPY --from=composer:2.9.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy base php config
COPY docker/php/conf.d/base.ini /usr/local/etc/php/conf.d/base.ini

# Dev Stage
FROM base AS dev
# Install Xdebug
RUN apk add --no-cache pcre-dev ${PHPIZE_DEPS} \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del pcre-dev ${PHPIZE_DEPS}

COPY docker/php/conf.d/dev.ini /usr/local/etc/php/conf.d/dev.ini
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]

# Build Stage (used for prod)
FROM base AS build
COPY src/composer.json src/composer.lock* ./
# Install dependencies without scripts first to cache layer
RUN if [ -f composer.json ]; then composer install --no-dev --no-scripts --no-autoloader --prefer-dist; fi
# Copy the rest of the app
COPY src/ .
# Dump autoload and run scripts
RUN if [ -f composer.json ]; then composer dump-autoload --optimize && composer run-script post-root-package-install || true && composer run-script post-create-project-cmd || true; fi

# Prod Stage
FROM base AS prod
COPY docker/php/conf.d/prod.ini /usr/local/etc/php/conf.d/prod.ini
# Install opcache
RUN docker-php-ext-install opcache

# Copy built code from build stage
COPY --from=build /var/www/html /var/www/html

COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
