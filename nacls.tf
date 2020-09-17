## NACL for private subnet 1 ##

resource "aws_network_acl" "Private_NACL_1" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = ["${aws_subnet.subnet3.id}"]

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
    Name = "Private_NACL_1"
  }
}

##NACL for Private Subnet 2 ##


resource "aws_network_acl" "Private_NACL_2" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = ["${aws_subnet.subnet4.id}"]

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
    cidr_block = "172.0.2.0/26"
    from_port  = 22
    to_port    = 22
  }
  egress {
    protocol   = "6"
    rule_no    = 4
    action     = "allow"
    cidr_block = "172.0.2.0/26"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "6"
    rule_no    = 5
    action     = "allow"
    cidr_block = "172.0.2.0/26"
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
    cidr_block = "172.0.2.0/26"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "6"
    rule_no    = 4
    action     = "allow"
    cidr_block = "172.0.2.0/26"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "6"
    rule_no    = 5
    action     = "allow"
    cidr_block = "172.0.2.0/26"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "Private_NACL_2"
  }
}

