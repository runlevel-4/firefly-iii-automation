#!/bin/bash

# Remove web components and firefly-iii directories
echo "This will reset the stage so you can start the installation from scratch"
cd
sudo rm -rf /var/www/html/firefly-iii
sudo rm -rf firefly-iii-automation
echo
echo "[ DONE ]"
echo
echo "Removing web components"
sudo apt autoremove --purge apache2 mysql-* mariadb-* php7.4-* -y
echo
echo "[ DONE ]"
