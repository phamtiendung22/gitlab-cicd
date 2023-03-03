FROM php:7.4.20-apache

RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libpq-dev \
    libxslt1-dev \
    libonig-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN apt-get update -y && apt-get install -y libonig-dev
RUN docker-php-ext-install \
    bcmath \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    xsl \
    zip \
    soap \
    sockets 

WORKDIR /var/www/html

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink ('compose-setup.php');" \
    && php composer.phar self-update \
    && php -r "unlink ('compose-setup.php');" \
    && mv composer.phar /usr/local/bin/composer 

COPY . /var/www/html

RUN composer install -n --prefer-dist
RUN chown -R www-data:www-data /var/www/html
RUN chown -R 755 /var/www/html

RUN php artisan config:cache
RUN php artisan route:cache
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
EXPOSE 80
RUN a2enmod rewrite headers

CMD ["apache2-foreground"]
