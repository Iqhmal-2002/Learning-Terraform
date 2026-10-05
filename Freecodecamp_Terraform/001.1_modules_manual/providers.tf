# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
  # cloud is the newer backend "remote"
  # for azure, need to learn backend "azurerm" later
  cloud {
    organization = "Learning_Terraform_2026"
    workspaces {
      name = "freecodecamp_terraform"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
