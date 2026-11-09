terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateiqhmal2026"
    container_name       = "storagecontainer"
    key                  = "050_complex.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "westus2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

#list:  ordered, duplicates allowed, accessed by position index [0], [1]
variable "regions" {
  type    = list(string)
  default = ["eastus", "westus", "eastus"]
}
# var.regions[0]  → "eastus"

#map: key → value, accessed by key. A dictionary in coding
variable "locations" {
  type    = map(string)
  default = { dev = "eastus", prod = "westus" }
}
# var.locations["prod"]  → "westus"

#set: no order, no duplicates, no [0]
variable "admins" {
  type    = set(string)
  default = ["iqhmal", "ops", "iqhmal"]   # becomes ["iqhmal", "ops"]; the duplicate is dropped
}

#object: fixed attribute names, each with its own type
#object is the default for { }
variable "vm" {
  type = object({
    name = string
    size = number
  })
  default = { name = "web-vm", size = 2 }
}
# var.vm.size  → 2

#tuple: fixed length, each position has its own type
#tuple is the default for [ ]
variable "rule" {
  type    = tuple([string, number, bool])
  default = ["allow-ssh", 22, true]
}
# var.rule[1]  → 22

resource "azurerm_resource_group" "env" {
  for_each = { dev = "eastus", prod = "westus" }
  name     = "rg-${each.key}"
  location = "westus2"
}
