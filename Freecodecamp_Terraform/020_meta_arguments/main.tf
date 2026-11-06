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
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# 2nd provider for alias example

provider "azurerm" {
  alias = "second"
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

variable "my_ip" {
  type        = string
  description = "My public IP address allowed to SSH to VM"
  validation {
    # Dynamically appends /32 to your IP string so cidrhost can validate it mathematically
    condition     = can(cidrhost("${var.my_ip}/32", 0))
    error_message = "The my_ip variable must be a valid standalone IPv4 address (e.g., 203.0.113.50)."
  }
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
  username = "azureuser"
}

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------
/*resource "azurerm_resource_group" "rg_1" {
  count    = 2
  name     = "count-${var.instance_name}-${count.index + 1}"
  location = "eastus"
  tags     = local.common_tags
}

resource "azurerm_resource_group" "rg_2" {
  for_each = {
    dev  = "eastus"
    prod = "westus"
  }
  name     = "for_each-${var.instance_name}-${each.key}"
  location = each.value
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "resource_ids_count" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.rg_1[*].id
}

output "resource_ids_for_each" {
  description = "ID of the resource group created"
  value       = values(azurerm_resource_group.rg_2)[*].id
}

output "resource_ids_for_each_for" {
  description = "IDs of the resource groups created"
  value       = { for k, rg in azurerm_resource_group.rg_2 : k => rg.id }
}
*/

locals {
  rg_names = ["alpha", "charlie"]
}

resource "azurerm_resource_group" "rg_count_rename2" {
  count    = length(local.rg_names)
  name     = "count-${local.rg_names[count.index]}"
  location = "eastus"
}

resource "azurerm_resource_group" "rg_foreach" {
  for_each = toset(local.rg_names)
  name     = "foreach-${each.key}"
  location = "eastus"
}

resource "azurerm_resource_group" "rg_alias" {
  provider = azurerm.second
  for_each = toset(local.rg_names)
  name     = "foreach-${each.key}"
  location = "eastus"
}

/*
moved{
  from = azurerm_resource_group.rg_count
  to  = azurerm_resource_group.rg_count_rename
}
*/

resource "azurerm_resource_group" "manual" {
  name     = "Portal_Created"
  location = "eastus"
}

import {
  to = azurerm_resource_group.manual
  id = "/subscriptions/510d58cf-bcf3-42a7-ab3b-ebac5b2e899d/resourceGroups/Portal_Created"
}