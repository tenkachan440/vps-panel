#!/bin/bash

echo "=== Updating system ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Installing dependencies ==="
sudo apt install -y curl wget zip unzip tar git software-properties-common ca-certificates lsb-release apt-transport-https

echo "=== Installing MariaDB ==="
sudo apt install -y mariadb-server

echo "=== Securing MariaDB ==="
sudo mysql -e "UPDATE mysql.user SET Password=PASSWORD('ptero123') WHERE User='root';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "=== Creating database ==="
sudo mysql -u root -pptero123 -e "CREATE DATABASE panel;"

echo "=== Installing PHP 8.2 ==="
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install -y php8.2 php8.2-cli php8.2-gd php8.2-mysql php8.2-curl php8.2-mbstring php8.2-xml php8.2-bcmath php8.2-zip php8.2-fpm

echo "=== Installing Composer ==="
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "=== Downloading Pterodactyl Panel ==="
sudo mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
sudo tar -xzvf panel.tar.gz
sudo rm panel.tar.gz

echo "=== Setting permissions ==="
sudo chown -R $USER:$USER /var/www/pterodactyl
sudo chmod -R 755 /var/www/pterodactyl/storage /var/www/pterodactyl/bootstrap/cache

echo "=== Configuring Laravel ==="
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=root --password=ptero123
php artisan migrate --force

echo "=== DONE ==="
echo "Untuk menjalankan panel:"
echo "cd /var/www/pterodact
