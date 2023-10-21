terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
   
    tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet GW"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "RT"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "keypar" {
  key_name   = "terraform_keypar"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZE2AWJTsCuxq+AZERyIxnvZ/A0zY2aQNB9BeTPCmEoUWlgWsEKt9tBtcQn7M29Z+HVb/0b6Nuxk76RcM6Ke+r3P1/vmc31qRzZVf1F9RoVlzUvXY3Ol220hSbKeta4f8jAlD0FJbvUtKod0x+0XshoDMlk9HY/0o+MB47j9WOZCj+AvBRfmoUeb9lzlBPGpq8uaJs2ckEgWSa7haQ881gsQjvOtHSJ56pZ2S3z2t6VPQkeDGLS3mRwffBtKLLeDM4ogtBuKYWnSmosnD+mcGw1/ZH+Ovq+La9tXbOUBfKHoOwUf/IBTx5vbryjCh4ugxlnH51oPh6w+KF8vNoGkGnvZYnYYWP4G6U4FaaVpT42tD2+XTogOh/RSg6NYEkKNcYfSrRSFdJ4pJxRABmkxkTUlYdtDMnuIAjPyMsPpSzBWUfk6qxJf2xVLbd9H3chlGYoog0bpab5mlFuW+vlnulVMGxmSkygB/E4z3olBMmwuXbfDTfAgQtElb1Iqb8LHE= mateus@PC-Gamer"
}

resource "aws_instance" "web" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  associate_public_ip_address = true
  key_name = aws_key_pair.keypar.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = {
    Name = "EC2 Terraform"
  }
}

resource "aws_security_group" "security_group" {
  name        = "imersaosg"
  description = "SG Liberado"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Liberar todas as portas"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "imersaosg"
  }
}

output "ip_ec2" {
  value = aws_instance.web.public_ip
  
}