# Use the official PHP image
FROM php:8.0-apache

# Install required PHP extensions
RUN docker-php-ext-install mysqli

# Copy application files to the container
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html

COPY default.conf /etc/apache2/sites-enabled/000-default.conf

# Set ownership
RUN chown -R www-data:www-data /var/www/html

# Run Apache and Expose port 80 443
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80 443

