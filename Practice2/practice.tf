#############
# VARIABLES #
#############

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-2"
}

#############
# PROVIDERS #
#############

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
}

########
# DATA #
########

data "aws_ami" "aws-linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# RESOURCES

resource "aws_instance" "nginx" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  key_name = var.key_name
  tags = {
    Name = "Linux"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "terraform-default-sg"

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


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

provisioner "remote-exec" {
  inline = [
  "sudo yum install nginx -y"
  "sudo service nginx start"
  ]
}

#OUTPUT
output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}
