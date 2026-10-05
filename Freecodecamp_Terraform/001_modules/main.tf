# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# MOVED to modules/network/main.tf
# # Create a resource group
# resource "azurerm_resource_group" "example_my_resource" {
#   #name     = "example-resources"
#   name      = var.instance_name
#   location  = "westus2"
#   tags      = local.common_tags
# }
#
# # Create a virtual network within the resource group
# resource "azurerm_virtual_network" "example_my_network" {
#   name                = "example-network"
#   # azurerm_resource_group under here needs the actual name of the resource group
#   resource_group_name = azurerm_resource_group.example_my_resource.name
#   location            = azurerm_resource_group.example_my_resource.location
#   address_space       = ["10.0.0.0/16"]
# }

# Call the child module. Each argument (left of =) fills a variable
# declared in modules/network/variables.tf
module "network" {
  source = "./modules/network"

  rg_name       = var.instance_name
  location      = "westus2"
  vnet_name     = "example-network"
  address_space = ["10.0.0.0/16"]
  tags          = local.common_tags
}

variable "instance_name" {
  type = string
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "azlab"
}

locals {
  name_prefix = "${var.project}-${var.env}"   # "azlab-dev"
  common_tags = {
    environment = var.env
    owner       = "iqhmal"
    managed_by  = "terraform"
  }
}