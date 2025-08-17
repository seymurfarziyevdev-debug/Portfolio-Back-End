FROM php:8.1-apache

# Lazımlı paketləri quraşdır
RUN apt-get update && apt-get install -y unzip git curl libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip

# Composer yüklə
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravel kodunu qovluğa kopyala
COPY . /var/www/html/

# Composer install işlət (vendor qovluğunu yaratmaq üçün)
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

# Public folderi root kimi göstər
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Apache konfiqurasiya
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Apache mod rewrite aktiv et
RUN a2enmod rewrite

# Laravel permission (opsional)

RUN mkdir -p storage/framework/sessions storage/framework/cache storage/framework/views storage/logs && \
    chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache


EXPOSE 80

RUN apt-get update && apt-get install -y libpq-dev


RUN docker-php-ext-install pdo_pgsql

