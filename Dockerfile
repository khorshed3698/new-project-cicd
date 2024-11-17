# Use the official PHP image
FROM php:8.0-apache

# Install required PHP extensions
RUN docker-php-ext-install mysqli

# Copy application files to the container
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html

# Copy Apache configuration
COPY default.conf /etc/apache2/sites-enabled/000-default.conf

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Make PHP scripts executable
RUN chmod -R 755 /var/www/html/vendor/bin/phpunit;

# Run Apache and expose ports
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80 443
