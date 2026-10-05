# Combined from 001.1_modules_manual (providers, variables, locals, main, outputs
# and modules/network). The network module is flattened: each module call is
# now written out as its own resource group + virtual network.

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  # cloud is the newer backend "remote"
  # for azure, need to learn backend "azurerm" later
  /*
  cloud {
    organization = "Learning_Terraform_2026"
    workspaces {
      name = "freecodecamp_terraform"
    }
  }
  */
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------
variable "instance_name" {
  type    = string
  default = "azlab-dev"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "azlab"
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------
locals {
  name_prefix = "${var.project}-${var.env}" # "azlab-dev"
  common_tags = {
    environment = var.env
    owner       = "iqhmal"
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Resources (was module "network")
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "example_my_resource" {
  name     = var.instance_name
  location = "westus2"
  tags     = local.common_tags

  provisioner "local-exec" {
    command = "echo Created ${self.name} with id ${self.id} >> rg_log.txt"
  }
}

resource "azurerm_virtual_network" "example_my_network" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example_my_resource.name
  location            = azurerm_resource_group.example_my_resource.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# Resources (was module "network2")
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "example_my_resource2" {
  name     = "rg2"
  location = "westus2"
  tags     = local.common_tags
}

# vnet name only needs to be unique within the resource group, so the same name is fine
resource "azurerm_virtual_network" "example_my_network2" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example_my_resource2.name
  location            = azurerm_resource_group.example_my_resource2.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "resource_id" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.example_my_resource.id
}
