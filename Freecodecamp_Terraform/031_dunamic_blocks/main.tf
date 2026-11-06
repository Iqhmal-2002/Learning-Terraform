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

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "azlab"
}

variable "instance_name" {
  type    = string
  default = "instance_1"
}

locals {
  name_prefix = "${var.project}-${var.env}" # "azlab-dev"
  common_tags = {
    environment = var.env
    owner       = "iqhmal"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "rg_1" {
  #name     = "example-resources"
  name     = var.instance_name
  location = "westus2"
  tags     = local.common_tags
}

resource "azurerm_network_security_group" "nsg_1" {
  resource_group_name = azurerm_resource_group.rg_1.name
  name                = "nsg-web-1" # argument  (name = value)
  location            = "eastus"  # argument

  security_rule { # nested block (name { ... }), no "="
    name     = "allow-ssh"
    priority = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
  }
}

variable "rules" {
  type = list(object({
    name     = string
    priority = number
    port     = string
  }))
  default = [
    { name = "allow-ssh", priority = 100, port = "22" },
    { name = "allow-http", priority = 110, port = "80" },
    { name = "allow-https", priority = 120, port = "443" },
  ]
}

resource "azurerm_network_security_group" "nsg_2" {
  name                = "nsg-web-2"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg_1.name

  dynamic "security_rule" { # ← name of the block to generate
    for_each = var.rules    # ← one block per item

    content { # ← what goes inside each block
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      destination_port_range     = security_rule.value.port
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

# ---------------------------------------------------------------------------
# Optional block: include a nested block only when a condition is true
# ---------------------------------------------------------------------------
variable "enable_ssh" {
  type    = bool
  default = true # flip to true (or -var="enable_ssh=true") and re-plan
}

resource "azurerm_network_security_group" "nsg_3" {
  name                = "nsg-optional"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg_1.name

  # Always present: a normal static block
  security_rule {
    name                       = "allow-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Only present when enable_ssh = true
  #   true  -> for_each = [1] -> one block generated
  #   false -> for_each = []  -> zero blocks generated
  # The "1" is just a placeholder; nothing reads security_rule.value here
  dynamic "security_rule" {
    for_each = var.enable_ssh ? [1] : []

    content {
      name                       = "allow-ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
