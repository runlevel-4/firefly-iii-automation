#!/bin/sh

# Check if Debain is installed.  If it is, install the php repositories
if grep -q Debian "/etc/os-release" ; then
	echo "Debian is installed"
	echo
	echo "Installing Debian prerequisites"
	echo
	sudo apt update
	sudo apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https
	wget https://packages.sury.org/php/apt.gpg
	sudo apt-key add apt.gpg
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.list
else
	echo "Not Debian...continuing"
fi

# Perform updates
sudo apt update && sudo apt upgrade -y

# Install web components
sudo apt install apache2 mysql-common mariadb-server php7.4 php7.4-bcmath php7.4-intl php7.4-curl php7.4-zip php7.4-gd php7.4-xml php7.4-mbstring php7.4-ldap php7.4-mysql php-mysql -y
echo
echo "Installing Composer (a friendly php helper that unpacks the php libraries contained within firefly and creates a firefly-iii project)..."
echo
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
echo
cd /var/www/html
echo
echo "If prompted, just hit Enter"
echo
sudo composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii 5.4.6

# This will stop the  white screen issue
# Changing firefly-iii folder permissions
sudo chown -R www-data:www-data firefly-iii
sudo chmod -R 775 firefly-iii/storage
echo
echo "Creating firefly database environment..."
echo
echo "Enter your MySQL root password.  If you don't have one, just hit Enter."
sudo mysql -u root -p < $HOME/firefly-iii-automation/mysql_setup.txt
sudo cp $HOME/firefly-iii-automation/.env /var/www/html/firefly-iii/

# Editing apache to allow modules
sudo cp $HOME/firefly-iii-automation/apache2.conf /etc/apache2/
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
