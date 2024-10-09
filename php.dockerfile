# Usar uma imagem base oficial do PHP 8.3 com Apache
FROM php:8.3-apache

# Instalar dependências do sistema, incluindo libpq-dev
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \    
    zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_pgsql \
    mbstring \
    xml \
    bcmath \
    zip \
    && a2enmod rewrite

# Instalar o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar arquivos do projeto para o container
COPY ./teste /var/www/html

# Instalar dependências do Laravel via Composer
RUN composer install

# Definir permissões corretas para as pastas de cache e logs do Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Gerar a chave do aplicativo Laravel
RUN php artisan key:generate

# Expor a porta 80
EXPOSE 80

# Iniciar o Apache
CMD ["apache2-foreground"]
