terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "random_string" "random_str" {
  length = 16
  special = false
  lower   = false
}

resource "aws_key_pair" "terraform_lab" {
  key_name   = random_string.random_str.result
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
    Name = "new3"
    test = "dianaKvitochka"
  }
}

resource "aws_security_group" "web-sg" {
  name = random_string.random_str.result
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


output "instance_instance_state" {
  value = aws_instance.app_server.instance_state
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}
