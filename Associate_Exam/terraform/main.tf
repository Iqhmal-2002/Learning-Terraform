terraform {
  cloud {
    organization = "Learning_Terraform_2026"
    workspaces {
      name = "terraform"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

variable "prefix" {
  type    = string
  default = "terraform"
}

resource "azurerm_resource_group" "rg1" {
  name     = "${var.prefix}-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "vn1" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vn1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic1" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_D2as_v4"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

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
  type = string
  default = "t3.micro"
}

locals {
  project_name = "terraform"
}

resource "aws_instance" "instance_1" {
  ami           = "ami-013f66a12d3857f32"
  instance_type = var.aws_instance_type

  tags = {
    Name = "MyServer-${local.project_name}"
  }
}

output "aws_instance_public_ip" {
  value = aws_instance.instance_1.public_ip
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