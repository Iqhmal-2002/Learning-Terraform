terraform {
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