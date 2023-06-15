# terraform introduction 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

# configuring the provider 

provider "aws" {
  region     = var.aws_region
  access_key = "AKIA3AOFDTDGTZSXA52H"
  secret_key = "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"
}

# create a vpc
resource "aws_vpc" "vpc_test" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name} vpc"
  }
}

resource "aws_internet_gateway" "server_igw" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "Server gateway"
  }
}

# public subnet this will allow our applcation to interact with the outside world.
resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = var.a_zs[1]
  map_public_ip_on_launch = true

  tags = {
    Name = var.pub_subnet
  }

}

#public subnet this will allow our applcation to interact with the outside world.
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = var.pub_subnet
  }

}

resource "aws_route_table" "serverRT" {
  vpc_id = aws_vpc.vpc_test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.server_igw.id
  }
  tags = {
    Name = "route table "
  }
}

# create a routetable association 
resource "aws_route_table_association" "routetable_assoc" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.serverRT.id
}

resource "aws_security_group" "network_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = var.egress_sg["from_port"]
    to_port     = var.egress_sg["to_port"]
    protocol    = var.egress_sg["protocol"]
    cidr_blocks = var.egress_sg["cidr_block"]
  }
}

data "template_file" "user_data" {
  template = file("./app-template.yml")
}

# using data source to fetch resource dynamically 
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "server_instance" {
  #ami                         = data.aws_ami.latest_amazon_linux.id
  ami                         = var.amis["${var.aws_region}"]
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.pub_subnet.id
  vpc_security_group_ids      = [aws_security_group.network_sg.id]

  # install and start apache webserver and start at run time 
  #user_data = file("userdata.sh")

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = var.instance_name
  }

}


