#!/bin/sh

# Check if Debain is installed.  If it is, install the php repositories
if grep -q Debian "/etc/os-release" ; then
	echo "Debian is installed"
	echo
	echo "Installing Debian prerequisites"
	echo
	sudo apt update
	sudo apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https unzip
	wget https://packages.sury.org/php/apt.gpg
	sudo apt-key add apt.gpg
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php8.list
else
	echo "Not Debian...continuing"
	echo
	echo "Adding Ubuntu PHP repos"
	echo
	# Add the PHP 8.0 repo
	sudo apt install ca-certificates apt-transport-https software-properties-common -y
	sudo add-apt-repository ppa:ondrej/php
	sudo add-apt-repository ppa:ondrej/apache2
fi

# Perform updates
sudo apt update && sudo apt upgrade -y

# Install web components
sudo apt install apache2 mysql-common mariadb-server php8.2 php8.2-common php8.2-bcmath php8.2-intl php8.2-curl php8.2-zip php8.2-gd php8.2-xml php8.2-mbstring php8.2-ldap php8.2-mysql php-mysql curl -y

# Install locales
locale-gen en_US.utf8 locale-gen nl_NL.utf8 update-locale
systemctl restart php8.0-fpm

echo
echo "Installing Composer (a friendly php helper that unpacks the php libraries contained within firefly and creates a firefly-iii project)..."
echo
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
echo
cd /var/www/html
echo
echo "If prompted, just hit Enter"
echo
echo "Unpacking firefly-iii project"
echo
sudo composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii 5.7.18
# This will stop the  white screen issue
# Changing firefly-iii folder permissions
sudo chown -R www-data:www-data firefly-iii
sudo chmod -R 775 firefly-iii/storage
echo
echo "Unpacking data importer for firefly-iii"
echo
sudo composer create-project firefly-iii/data-importer --no-dev --prefer-dist data-importer 1.0.2
sudo chown -R www-data:www-data data-importer
sudo chmod -R 775 data-importer/storage
sudo cp firefly-iii/data-importer/.env.example .env
echo
# Create database environment
echo "Creating firefly database environment..."
echo
echo "Enter your MySQL root password.  If you don't have one, just hit Enter."
sudo mysql -u root -p < $HOME/firefly-iii-automation/mysql_setup.sql
sudo cp $HOME/firefly-iii-automation/.env /var/www/html/firefly-iii/

# Editing apache to allow modules
sudo cp $HOME/firefly-iii-automation/apache2.conf /etc/apache2/
sudo a2dismod php7.4
sudo a2enmod php8.0
sudo a2enmod rewrite

#Setup Artisan
cd /var/www/html/firefly-iii
sudo php artisan migrate:refresh --seed
sudo php artisan firefly-iii:upgrade-database
sudo php artisan passport:install
sudo php artisan key:generate

# Restart apache web service
sudo service apache2 restart
echo
echo "All done..."
echo
echo "You should now be able to visit http://<ipaddress>/firefly-iii/public"
echo
echo "Grab the IP Address from below"
echo
ip address
