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
  availability_zone = "${var.az2}"

  tags = {
    Name = "public-subnet-2"
  }

}

resource "aws_subnet" "subnet3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.0.2.0/26"
  availability_zone = "${var.az1}"

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
  user_data              = file("wpinstall.sh")

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

/* resource "aws_network_acl" "Private_NACL" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = ["${aws_subnet.subnet3.id}", "${aws_subnet.subnet4.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "172.0.0.0/26"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 2
    action     = "allow"
    cidr_block = "172.0.1.0/26"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "6"
    rule_no    = 3
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 22
    to_port    = 22
  }
  egress {
    protocol   = "6"
    rule_no    = 4
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "6"
    rule_no    = 5
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "-1"
    rule_no    = 1
    action     = "allow"
    cidr_block = "172.0.0.0/26"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 2
    action     = "allow"
    cidr_block = "172.0.1.0/26"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "6"
    rule_no    = 3
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "6"
    rule_no    = 4
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "6"
    rule_no    = 5
    action     = "allow"
    cidr_block = "172.0.3.0/26"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "Private_NACL"
  }
} */

