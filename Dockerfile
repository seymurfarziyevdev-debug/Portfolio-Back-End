FROM php:8.1-apache

# Gerekli paketleri yükle
RUN apt-get update && apt-get install -y unzip git curl libzip-dev zip libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql zip

# Composer'ı kopyala
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Projeyi kopyala
COPY . /var/www/html/

# .env dosyasını oluştur
RUN cp /var/www/html/.env.example /var/www/html/.env

# Composer install
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/html

# Laravel APP_KEY üret
RUN php /var/www/html/artisan key:generate

# Cache temizle ve oluştur
RUN php /var/www/html/artisan config:clear \
    && php /var/www/html/artisan cache:clear \
    && php /var/www/html/artisan config:cache

# Apache document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Apache ayarları
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# mod_rewrite aktif et
RUN a2enmod rewrite

# Laravel izin ayarları
RUN mkdir -p storage/framework/sessions storage/framework/cache storage/framework/views storage/logs \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80
