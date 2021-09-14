# firefly-iii install
This script assumes you are running a flavor of Linux that includes apt package manager.

**NOTE FOR DEBIAN/RPi USERS:** You will have to add the third party _sury_ repo to get the php packages.

`sudo apt update`

`sudo apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https`

`wget https://packages.sury.org/php/apt.gpg`

`sudo apt-key add apt.gpg`

`echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.list`

`sudo apt update`

================================================

At the terminal:

  1. If you don't have _git_ installed, just run `sudo apt install git`.
  2. `sudo git clone https://github.com/edwardsj9090/firefly-iii-automation`
  3. `cd firefly-iii-automation`

**DO NOT** run the installer script as sudo or root.  Just run `sh installlampwithfirefly.sh`.
 
 If you have permission issues when running the .sh script without sudo, then try this:
 
 `chmod +x /path/to/your/filename.sh`

==========================================================

Post-Install (OPTIONAL):

I would recommend changing the firefly mysql connection string defaults in **/var/www/html/firefly-iii/.env** file.

  1.  Change the password for the mysql firefly user.

        Login to your MySQL instance: `sudo mysql -u root -p` (if you don't have a mysql root passowrd, press _Enter_ although I recommend changing that too).
        
        Change the firefly user's password: `ALTER USER 'firefly'@'localhost' IDENTIFIED BY 'newpassword';`
        
  2. Edit the **.env** file in **/var/www/html/firefly-iii/** and change the **DB_PASSWORD** parameter to the new password you created for the mysql firefly user.

        `sudo nano /var/www/html/firefly-iii/.env`

         DB_CONNECTION=mysql

         DB_HOST=localhost

         DB_PORT=3306

         DB_DATABASE=firefly

         DB_USERNAME=firefly

         DB_PASSWORD=secret_firefly_password
         
===========================================================

## Acknowledgements

@JC5 for this awesome firefly-iii financial management app :)
