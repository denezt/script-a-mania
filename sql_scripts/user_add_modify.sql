-- Initial Update to modify password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'mypassword'

-- Modify Admin Grant Access to every db resource
GRANT ALL ON *.* to 'admin'@'localhost' IDENTIFIED BY 'password'; 
GRANT ALL ON *.* to 'admin'@'%' IDENTIFIED BY 'password'; 

-- Create sysadmin User allow access from localhost
CREATE USER 'sysadmin'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'sysadmin'@'localhost' WITH GRANT OPTION;

-- Create sysadmin User allows access from anywhere
CREATE USER 'sysadmin'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'sysadmin'@'%' WITH GRANT OPTION;

-- Create Admin User
CREATE USER 'admin'@'localhost';
GRANT RELOAD,PROCESS ON *.* TO 'admin'@'localhost';
CREATE USER 'myuser'@'localhost';
