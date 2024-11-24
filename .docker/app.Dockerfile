# Use an official PHP image with required extensions for Laravel
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    zip \
    unzip \
    git \
    nginx \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    nodejs \
    npm \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    gd \
    zip \
    bcmath \
    opcache \
    && docker-php-ext-enable \
    pdo_mysql \
    mbstring \
    gd \
    zip \
    bcmath \
    opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy Laravel project files
COPY . /var/www/html/

# Set permissions and ownership for Laravel files
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Node.js dependencies
RUN npm install && npm run build

# Set php-fpm config
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf

# Switch to www-data user
USER www-data

# Install Laravel dependencies
RUN composer install --optimize-autoloader --no-dev

# Start PHP-FPM
CMD ["php-fpm"]