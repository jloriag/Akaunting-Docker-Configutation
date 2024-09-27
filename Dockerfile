# Usar la última versión de Ubuntu como imagen base
FROM ubuntu:latest

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Actualizar los repositorios y asegurarse de que todo esté actualizado
RUN apt-get update && apt-get upgrade -y

# Instalar dependencias para PHP, Apache, curl, git, unzip y otras necesarias
RUN apt-get install -y \
    apache2 \
    curl \
    git \
    unzip \
    zip \
    software-properties-common \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    nodejs \
    npm

# Agregar el repositorio de PHP y actualizar el índice de paquetes
RUN add-apt-repository ppa:ondrej/php -y && apt-get update

# Instalar PHP 8.3 y las extensiones necesarias para Akaunting
RUN apt-get install -y \
    php8.3 \
    php8.3-cli \
    php8.3-fpm \
    php8.3-mbstring \
    php8.3-zip \
    php8.3-curl \
    php8.3-gd \
    php8.3-mysql \
    php8.3-xml

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Actualizar npm a la última versión
RUN npm install -g npm

# Descargar Akaunting y descomprimirlo en el directorio de trabajo
RUN git clone https://github.com/akaunting/akaunting.git && \
    composer install && \
    npm install && \
    npm run dev

RUN php artisan install --db-name="akaunting" --db-username="rootpassword" --db-password="akaunting" --admin-email="jloriag@company.com" --admin-password="123456"

# Habilitar mod_rewrite de Apache para que Akaunting funcione correctamente
RUN a2enmod rewrite

# Cambiar el DocumentRoot de Apache para apuntar al directorio público de Akaunting
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

# Exponer el puerto 80 para Apache
EXPOSE 80

# Iniciar Apache
CMD ["apachectl", "-D", "FOREGROUND"]
