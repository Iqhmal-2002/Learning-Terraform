terraform {
  cloud {
    organization = "Learning_Terraform_2026"
    workspaces {
      name = "terraform-aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

###################################################################################
# AWS Provider and Resources
###################################################################################

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

// Changing region requires advanced feature
// which requires PAYG upgrade
/*
provider "aws" {
  profile = "default"
  region  = "eu-west-1"
  alias = "west-1"
}*/

variable "aws_instance_type" {
  type    = string
  default = "t3.micro"
}

locals {
  project_name = "terraform"
}

resource "aws_instance" "instance_1" {
  ami                    = "ami-013f66a12d3857f32"
  instance_type          = var.aws_instance_type
  key_name               = aws_key_pair.kp1.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  provisioner "local-exec" {
    command = "echo ${self.private_ip} > private_ip.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "echo hello from terraform > /tmp/hello.txt",
      "cat /tmp/hello.txt",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo instance ${self.id} destroyed >> destroy_log.txt"
  }
  provisioner "file" {
    content = "file provisioner"
    destination = "/home/ec2-user/barsoon.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "MyServer-${local.project_name}"
  }
}

output "aws_instance_public_ip" {
  value = aws_instance.instance_1.public_ip
}

resource "aws_key_pair" "kp1" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/id_rsa.pub") # the key you made for the Azure VM
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_security_group" "ssh" {
  name = "allow-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"] # your IP only, not 0.0.0.0/0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Sample of using terraform module to create VPC in AWS 
// 1 of 38 have issues due to free tier limit, so commented out for now
// Also personally dont really like using modules pulled from the registry 
// so will just use the resource blocks instead and making my own modules later on if needed
/*
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  # providers = {
  #   aws = aws.west-1
  # }

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
*/