# Use official PHP image with Apache
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    && docker-php-ext-install pdo_mysql zip gd

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Set working directory to the project root
WORKDIR /var/www/html

# Copy Lumen application to container
COPY . /var/www/html

# Install Composer (Dependency Manager)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Run Composer to install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set working directory to public for Apache to serve files
WORKDIR /var/www/html/public

# Copy custom Apache configuration
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Enable the site configuration
RUN a2ensite 000-default.conf

# Set permissions for Lumen project
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Set entry point
CMD ["apache2-foreground"]
