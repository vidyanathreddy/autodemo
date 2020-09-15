##VPC##
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main"
  }

}

##Subnets##

resource "aws_subnet" "subnet1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.0.0.0/26"
  availability_zone = "${var.az1}"

  tags = {
    Name = "public-subnet-1"
  }

}
resource "aws_subnet" "subnet2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.0.1.0/26"
  availability_zone = "${var.az1}"

  tags = {
    Name = "public-subnet-2"
  }

}

resource "aws_subnet" "subnet3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.0.2.0/26"
  availability_zone = "${var.az2}"

  tags = {
    Name = "private-subnet-1"
  }

}
resource "aws_subnet" "subnet4" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.0.3.0/26"
  availability_zone = "${var.az2}"

  tags = {
    Name = "private-subnet-2"
  }

}

##PublicSG##
resource "aws_security_group" "for_public" {
  name        = "public_SG"
  description = "Security Group for instances in public subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS From Everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from Everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from Everywehere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_SG"
  }
}

##PrivateSG##

resource "aws_security_group" "for_private" {
  name        = "private_SG"
  description = "Security Group for instances in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_SG"
  }
}

##internet-gw##

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Internet Gateway"
  }
}

##natgw##

resource "aws_eip" "natIP" {
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.natIP.id}"
  subnet_id     = "${aws_subnet.subnet2.id}"

  tags = {
    Name = "NAT Gateway"
  }
}


##Public and Private RTs##
resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "Private Route Table"
  }
}

##RT-Associations##

resource "aws_route_table_association" "public-rt-association-1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}
resource "aws_route_table_association" "public-rt-association-2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}

resource "aws_route_table_association" "private-rt-association-1" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}
resource "aws_route_table_association" "private-rt-association-2" {
  subnet_id      = "${aws_subnet.subnet4.id}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}

###Endpoints and Association with RT##
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.us-east-1.s3"
}


resource "aws_vpc_endpoint_route_table_association" "endpoint-route-table-association" {
  route_table_id  = "${aws_route_table.private-route-table.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

##AWS Instance##

resource "aws_instance" "wp_ubuntu" {
  ami                    = "ami-06b263d6ceff0b3dd"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.for_public.id}"]
  subnet_id              = aws_subnet.subnet1.id
  key_name               = "try"
  user_data              = <<-EOF
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
                           EOF

  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = 8
  }
  tags = {
    Name        = "ub-wordpress"
    Environment = "test"
    Project     = "test-proj"
  }

  /*  provisioner "file" {
    source      = "./wpinstall.sh"
    destination = "/home/ubuntu/wpinstall.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/wpinstall.sh",
      "sudo sh /home/ubuntu/wpinstall.sh",
    ]
  } */

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file("./try.pem")
    host        = self.public_ip
  }

}

