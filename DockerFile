# Utilise l'image officielle PHP 8.2 avec Apache pré-configuré
FROM php:8.2-apache

# Active les extensions PostgreSQL obligatoires pour le fichier database.php
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# Active le module d'écriture d'URL Apache si besoin
RUN a2enmod rewrite

# Copie l'intégralité de votre projet dans le dossier du serveur web
COPY . /var/www/html/

# Donne les droits de lecture et d'écriture au serveur
RUN chown -R www-data:www-data /var/www/html/

# Expose le port 80 pour le site internet
EXPOSE 80
