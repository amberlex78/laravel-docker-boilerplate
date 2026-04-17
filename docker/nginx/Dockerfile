FROM nginx:1.30.0-alpine AS base

# Remove default nginx config
RUN rm -rf /etc/nginx/conf.d/*

# Copy our configs
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Dev Stage
FROM base AS dev
# Volumes handle the code mapping

# Prod Stage
FROM base AS prod
# Copy public folder to serve static files
COPY src/public /var/www/html/public
