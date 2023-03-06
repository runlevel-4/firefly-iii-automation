# WIP: integrating this script or something like it with the install script:
# https://gist.github.com/pedrom34/d1b8ab84e1e9ec7e8c6cbcc3cc51d663

#!/bin/sh

# Check if Firefly III is installed
if [ -d /var/www/html/firefly-iii ]; then
  # Move into the Firefly III directory
  cd /var/www/html/firefly-iii

  # Get the latest version of Firefly III
  latestversion=$(curl -s https://api.github.com/repos/firefly-iii/firefly-iii/releases/latest  | grep -oP '"tag_name": "\K(.*)(?=")')

  # Reinstall Firefly III with the latest version
  sudo composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii-updated $latestversion

  # Copy necessary files to the new installation
  cp .env firefly-iii-updated/.env
  cp storage/upload/* firefly-iii-updated/storage/upload/
  cp storage/export/* firefly-iii-updated/storage/export/

  # If using SQLite, copy the database to the new installation
  if [ -f database/firefly-iii.sqlite ]; then
    cp database/firefly-iii.sqlite firefly-iii-updated/database/firefly-iii.sqlite
  fi

  # Perform upgrade commands
  cd firefly-iii-updated
  rm -rf bootstrap/cache/*
  php artisan cache:clear
  php artisan migrate --seed
  php artisan firefly-iii:upgrade-database
  php artisan passport:install
  php artisan cache:clear
  cd ..

  # Move the new installation to replace the old installation
  mv firefly-iii firefly-iii-old
  mv firefly-iii-updated firefly-iii

  # Set appropriate permissions
  chown -R www-data:www-data firefly-iii
  chmod -R 775 firefly-iii/storage

  # Restart Apache2
  sudo systemctl restart apache2

else
    echo "Firefly III is not installed. Proceeding with installation..."

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

# Ensure en_US.UTF-8 locale is installed
printf "en_US.UTF-8 UTF-8\n"  >>  /etc/locale.gen
locale-gen

# Install web components
sudo apt install apache2 mysql-common mariadb-server php8.2 php8.2-common php8.2-bcmath php8.2-intl php8.2-curl php8.2-zip php8.2-gd php8.2-xml php8.2-mbstring php8.2-ldap php8.2-mysql php-mysql curl -y

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
echo "You should now be able to visit http://<ipaddress>/firefly-iii/public for the Firefly III interface and http://<ipaddress>/data-importer/public for the data importer."
echo "Some configuration will be needed for the data importer. See https://docs.firefly-iii.org/data-importer/install/configure/"
echo
echo "Grab the IP Address from below"
echo
ip address
fi