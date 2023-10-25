//This Terraform Template creates a jenkins and docker server on AWS EC2 Instance
//Jenkins server will run on Amazon Linux 2 with custom security group
//allowing SSH (22), Http-s (80-443) and TCP (8080) connections from anywhere.
//User needs to select appropriate variables from "variable.tf" file when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "tf-jenkins-server" {
  ami                    = var.myami
  instance_type          = var.instancetype
  key_name               = var.mykey
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data              = file("install-jenkins.sh")
  tags = {
    Name = var.tags
  }

}

resource "null_resource" "forpasswd" {
  depends_on = [aws_instance.tf-jenkins-server]

  provisioner "local-exec" {
    command = "sleep 300"
  }

  # Do not forget to define your key file path correctly!
  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/${var.mykey}.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@${aws_instance.tf-jenkins-server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > initialpasswd.txt"
  }
}

resource "aws_instance" "tf-docker-server" {
  depends_on             = [aws_instance.tf-jenkins-server, null_resource.forpasswd]
  ami                    = var.myami
  instance_type          = var.instancetype
  key_name               = var.mykey
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  user_data              = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              # install docker-compose
              curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
              -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
	            EOF

  tags = {
  Name = "Docker-engine" }
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH (22), Http-s (80-443) and TCP (8080) inbound traffic"

  dynamic "ingress" {
    for_each = var.secgr-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
