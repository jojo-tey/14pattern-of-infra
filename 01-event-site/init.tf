provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}


# VPC 

resource "aws_vpc" "event-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "event-vpc"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.event-vpc.id
}

# Custom Route Table

resource "aws_route_table" "eventsite-route-table" {
  vpc_id = aws_vpc.eventsite-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Eventsite"
  }
}

# Subnet

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.eventsite-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    name = "eventsite-subnet"
  }
}

# Associate subnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.eventsite-route-table.id
}




# AWS Route53 Zone 
resource "aws_route53_zone" "eventsite_com" {
  name = "eventsite.com"
}

# MX Record
resource "aws_route53_record" "eventsite_com_mx" {
  zone_id = aws_route53_zone.eventsite_com.zone_id
  name    = "eventsite_com.com"
  type    = "MX"
  ttl     = "3600"
  records = [
    "1 ASPMX.L.GOOGLE.COM.",
    "5 ALT1.ASPMX.L.GOOGLE.COM.",
    "5 ALT2.ASPMX.L.GOOGLE.COM.",
    "10 ALT3.ASPMX.L.GOOGLE.COM.",
    "10 ALT4.ASPMX.L.GOOGLE.COM."
  ]
}

# CNAME Record
resource "aws_route53_record" "eventsite_com" {
  zone_id = aws_route53_zone.eventsite_com.zone_id
  name    = "app.eventsite.com."
  type    = "CNAME"
  ttl     = "300"
  records = ["www.eventsite.com"]
}

resource "aws_route53_record" "test_eventsite_com" {
  zone_id = aws_route53_zone.eventsite_com.zone_id
  name    = "test.eventsite.com."
  type    = "CNAME"
  ttl     = "300"
  records = ["www.eventsite.com"]
}

# Security group

resource "aws_security_group" "eventsite_sg" {
  name        = "eventsite_sg"
  description = "Eventsite inbound traffic"
  vpc_id      = aws_vpc.eventsite-vpc.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
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
    Name = "eventsite_sg"
  }
}

# Network interface with an ip in the subnet

resource "aws_network_interface" "eventsite-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.eventsite_sg.id]
}

# Assign an elastic IP to the network interface 

resource "aws_eip" "eventsite-ip" {
  vpc                       = true
  network_interface         = aws_network_interface.eventsite-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
}

# EBS volume

resource "aws_ebs_volume" "eventsite-vol" {
  availability_zone = "eu-central-1a"
  size              = 40

  tags = {
    Name = "eventsite-vol"
  }
}


# Server setting

resource "aws_instance" "eventsite-server-instance" {
  ami           = var.AMIS
  instance_type = "t2.micro"


  availability_zone = "eu-central-1a"
  key_name          = "test"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eventsite-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum groupinstall "Web Server"
                sudo yum groupinstall "PHP Support"
                sudo yum groupinstall "MySQL Database"
                sudo yum install php-mysql
                sudo service httpd start
                sudo chkconfig httpd on
                sudo service mysqld start
                sudo chkconfig mysqld on
                sudo mysql_secure_installation
                EOF
  tags = {
    Name = "eventsite-server"
  }
}
