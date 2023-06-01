terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_key_pair" "terraform_lab" {
  key_name   = "id_rsa.pub"
  public_key = "${file("id_rsa.pub")}"
}


provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-03f65b8614a860c29"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.terraform_lab.key_name}"
  user_data = "${file("install_apache.sh")}"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "lab2"
  }
}

output "app_servers_ips" {
  value = {
    for server in aws_instance.app_server :
    server.id => server.public_ip
  }
}

output "instance_instance_state" {
  value = aws_instance.app_server.instance_state
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

resource "aws_security_group" "web-sg" {
  name = "test-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}
