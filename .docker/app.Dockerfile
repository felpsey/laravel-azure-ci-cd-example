# Use the official PHP 8.3 Apache image as the base
FROM php:8.3-apache

# Set working directory
WORKDIR /var/www/html

# Update package list and install required dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install zip pdo_mysql

# Enable Apache mod_rewrite for Laravel's routing
RUN a2enmod rewrite

# Copy Composer from its official image
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

# Copy the Laravel project files to the container
COPY . /var/www/html

# Set proper permissions for the Laravel files
RUN chown -R www-data:www-data /var/www/html

# Switch to www-data user for running the web server
USER www-data

# Install Laravel dependencies using Composer
RUN composer install --no-dev --optimize-autoloader

# Expose the default HTTP port
EXPOSE 80

# Start the Apache server as www-data
CMD ["apache2-foreground"]