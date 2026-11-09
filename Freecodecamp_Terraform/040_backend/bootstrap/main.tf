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

# Create a resource group
resource "azurerm_resource_group" "bootstrap" {
  name     = "rg-tfstate"
  location = "westus2"
}

resource "azurerm_storage_account" "bootstrap" {
  name                     = "sttfstateiqhmal2026"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "bootstrap" {
  name                  = "storagecontainer"
  storage_account_id    = azurerm_storage_account.bootstrap.id
  container_access_type = "private"
}