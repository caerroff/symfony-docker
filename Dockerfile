FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git zip unzip libpng-dev npm \
    libzip-dev default-mysql-client libicu-dev

    RUN docker-php-ext-configure intl
    RUN docker-php-ext-install pdo pdo_mysql zip gd intl
    # RUN docker-php-ext-enable intl
    
COPY ./apache-config/* /etc/apache2/sites-available
RUN a2enmod rewrite

WORKDIR /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html/*

COPY migrate.sh /usr/local/bin

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-scripts --no-autoloader
RUN npm i
RUN npm run build

RUN chmod 0777 /usr/local/bin/migrate.sh

EXPOSE 80

RUN sed -i 's!/var/www/html!/var/www/html/public!g' \
    /etc/apache2/sites-available/000-default.conf 

CMD ["apache2-foreground"]