# PHP 8.3 + Apache optimized for Laravel in Kubernetes
FROM php:8.3-apache-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_NO_INTERACTION=1 \
    COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies and PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git unzip curl \
        libcurl4-openssl-dev \
        libzip-dev libpng-dev libxml2-dev libonig-dev \
        libwebp-dev libjpeg-dev libfreetype6-dev libicu-dev \
        libgmp-dev libsasl2-dev libsqlite3-dev \
        zlib1g-dev gnupg && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    docker-php-ext-install \
        pdo_mysql mysqli curl mbstring xml zip gd intl gmp && \
    docker-php-ext-enable pdo_mysql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Apache config
COPY apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY mpm_prefork.conf /etc/apache2/conf-available/mpm_prefork.conf
RUN a2enmod rewrite headers deflate expires && a2enconf mpm_prefork

# PHP config
COPY php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Permissions (hostPath will override this)
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD apache2ctl configtest || exit 1

CMD ["apache2-foreground"]
