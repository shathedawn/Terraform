provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "Hello" {
  ami           = "ami-00c03f7f7f2ec15c3"
  instance_type = "t2.micro"
  key_name = "terraform"
  tags = {
    Name = "Linux"
  }
  user_data = <<-EOF
    #! /bin/bash
      #Shell to Install Jenkins
      sudo yum install java-1.8.0 -y
      sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
      sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
      sudo yum install jenkins -y
      sudo service jenkins start
    EOF
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
