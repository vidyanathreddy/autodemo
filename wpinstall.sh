#!/bin/bash 

wordpress_db_name=wpdb
db_root_password=admin123
pwd = $(pwd)
 
 ## Update system  
 sudo apt-get update -y  
   
 ## Install Apache  
 sudo apt-get install apache2 apache2-utils -y  
 sudo systemctl start apache2  
 sudo systemctl enable apache2  
   
 ## Install PHP  
 sudo apt-get install php libapache2-mod-php php-mysql -y  
   
 ## Install MySQL database server  
 sudo export DEBIAN_FRONTEND="noninteractive"  
 sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"  
 sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"  
 sudo apt-get install mysql-server mysql-client -y  
   
 ## Install Latest WordPress  
 sudo rm /var/www/html/index.*  
 sudo wget -c http://wordpress.org/latest.tar.gz  
 sudo tar -xzvf latest.tar.gz  
 sudo rsync -av wordpress/* /var/www/html/  
   
 ## Set Permissions  
 sudo chown -R www-data:www-data /var/www/html/  
 sudo chmod -R 755 /var/www/html/  
   
 ## Configure WordPress Database  
 sudo mysql -uroot -p$db_root_password <<QUERY_INPUT  
 CREATE DATABASE $wordpress_db_name;  
 GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_root_password';  
 FLUSH PRIVILEGES;  
 EXIT  
 QUERY_INPUT  
   
 ## Add Database Credentias in wordpress  
 cd /var/www/html/  
 sudo mv wp-config-sample.php wp-config.php  
 sudo perl -pi -e "s/database_name_here/$wordpress_db_name/g" wp-config.php  
 sudo perl -pi -e "s/username_here/root/g" wp-config.php  
 sudo perl -pi -e "s/password_here/$db_root_password/g" wp-config.php  
   
 ## Enabling Mod Rewrite  
 sudo a2enmod rewrite  
 sudo php5enmod mcrypt  
   
 ## Install PhpMyAdmin  
 sudo apt-get install phpmyadmin -y  
   
 ## Configure PhpMyAdmin  
 sudo echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf  
   
 ## Restart Apache and Mysql  
 sudo service apache2 restart  
 sudo service mysql restart  
   
 ## Cleaning Download  
 sudo cd $pwd  
 sudo rm -rf latest.tar.gz wordpress  
   
