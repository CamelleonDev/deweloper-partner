# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS frontend

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY vite.config.js ./
COPY resources ./resources
COPY public ./public

RUN npm run build

FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --prefer-dist --optimize-autoloader

COPY . .
RUN composer dump-autoload --optimize

FROM php:8.4-fpm-bookworm AS app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gettext \
    git \
    libzip-dev \
    unzip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j"$(nproc)" opcache pdo_mysql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY --from=vendor /app /var/www/html
COPY --from=frontend /app/public/build /var/www/html/public/build

RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-laravel.ini

COPY railway /var/www/html/railway
RUN chmod +x /var/www/html/railway/*.sh

# cli stage kept for documentation; Railway always builds the LAST stage (web)
FROM app AS cli

CMD ["php-fpm", "-F"]

FROM app AS web

RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

COPY docker/nginx/railway.conf.template /etc/nginx/templates/railway.conf.template
COPY docker/entrypoint-web.sh /usr/local/bin/entrypoint-web.sh
RUN chmod +x /usr/local/bin/entrypoint-web.sh

EXPOSE 8080

CMD ["/usr/local/bin/entrypoint-web.sh"]
