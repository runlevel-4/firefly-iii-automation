# firefly-iii install
This script assumes you are running a flavor of Linux that includes apt package manager.

================================================

At the terminal:

  1. If you don't have _git_ installed, just run `sudo apt install git`.
  2. `git clone https://github.com/runlevel-4/firefly-iii-automation`
  3. `cd firefly-iii-automation`

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
