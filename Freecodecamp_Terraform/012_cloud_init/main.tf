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
resource "azurerm_resource_group" "rg_1" {
  name     = var.instance_name
  location = "eastus"
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet_1" {
  name                = "vnet-${var.instance_name}"
  resource_group_name = azurerm_resource_group.rg_1.name
  location            = azurerm_resource_group.rg_1.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags

}

#subnets inherits location from VNet, and Azure doesnt support tags on subnets, so no tags here
resource "azurerm_subnet" "subnet_1" {
  name                 = "subnet_1"
  resource_group_name  = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip_1" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.rg_1.name
  location            = azurerm_resource_group.rg_1.location
  # standard sku only allows static
  # basic sku was retired so GG choices
  allocation_method = "Static"
  sku               = "Standard"
  tags              = local.common_tags
}

resource "azurerm_network_security_group" "nsg_1" {
  name                = "nsg_1"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  tags                = local.common_tags
  security_rule {
    name      = "Allow-SSH-MyIP"
    priority  = 100
    direction = "Inbound"
    access    = "Allow"
    # Somehow Tcp is case sensitive
    protocol = "Tcp"
    # port from laptop is ephemeral, so allow all source ports, but only allow destination port 22 (SSH)
    source_port_range      = "*"
    destination_port_range = "22"
    # this is the whitelisted IP address of the laptop, so only allow SSH from that IP
    source_address_prefix = var.my_ip
    # by the time this hits the VM, it will be NATed to the VM's private IP, so allow all destination addresses
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-Port-80-MyIP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-Port-443-MyIP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic_1.id
  network_security_group_id = azurerm_network_security_group.nsg_1.id
}

resource "azurerm_network_interface" "nic_1" {
  name                = "nic_1"
  location            = azurerm_resource_group.rg_1.location
  resource_group_name = azurerm_resource_group.rg_1.name
  tags                = local.common_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_1" {
  name                = "vm-1"
  resource_group_name = azurerm_resource_group.rg_1.name
  location            = azurerm_resource_group.rg_1.location
  size                = "Standard_D2as_v4"
  admin_username      = local.username
  custom_data         = base64encode(file("${path.module}/userdata.yaml"))
  network_interface_ids = [
    azurerm_network_interface.nic_1.id,
  ]
  tags       = local.common_tags
  depends_on = [azurerm_network_interface_security_group_association.nic_nsg_assoc]
  admin_ssh_key {
    username   = local.username
    public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "resource_id" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.rg_1.id
}

output "public_ip_address" {
  value       = azurerm_linux_virtual_machine.vm_1.public_ip_address
  description = "Public IP address of the VM"
}