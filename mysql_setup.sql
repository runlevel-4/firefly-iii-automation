CREATE DATABASE firefly;
CREATE USER 'firefly'@'localhost' IDENTIFIED BY 'secret_firefly_password';
GRANT ALL PRIVILEGES ON firefly.* TO 'firefly'@'localhost';
