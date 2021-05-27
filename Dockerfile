FROM php:8.0-apache 
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN pecl install xdebug && docker-php-ext-enable xdebug

WORKDIR /var/www/html
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
