terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  cloud {
    organization = "Learning_Terraform_2026"
    workspaces {
      name = "learn-terraform-azure-2"
    }
  }
}

provider "azurerm" {
  features {}
}