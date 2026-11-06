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
# Resources (was module "network")
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "example_my_resource" {
  name     = var.instance_name
  location = "eastus"
  tags     = local.common_tags

  /*
  provisioner "local-exec" {
    command = "echo Created ${self.name} with id ${self.id} >> rg_log.txt"
  }
*/

}

resource "azurerm_virtual_network" "example_my_network" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example_my_resource.name
  location            = azurerm_resource_group.example_my_resource.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags

}

#subnets inherits location from VNet, and Azure doesnt support tags on subnets, so no tags here
resource "azurerm_subnet" "example_my_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example_my_resource.name
  virtual_network_name = azurerm_virtual_network.example_my_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example_public_ip" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.example_my_resource.name
  location            = azurerm_resource_group.example_my_resource.location
  # standard sku only allows static
  # basic sku was retired so GG choices
  allocation_method = "Static"
  sku               = "Standard"
  tags              = local.common_tags
}

resource "azurerm_network_security_group" "example_nsg" {
  name                = "example-nsg"
  location            = azurerm_resource_group.example_my_resource.location
  resource_group_name = azurerm_resource_group.example_my_resource.name
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
}

resource "azurerm_network_interface_security_group_association" "example_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.example_nic.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_my_resource.location
  resource_group_name = azurerm_resource_group.example_my_resource.name
  tags                = local.common_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "example_vm" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example_my_resource.name
  location            = azurerm_resource_group.example_my_resource.location
  size                = "Standard_D2as_v4"
  admin_username      = local.username
  network_interface_ids = [
    azurerm_network_interface.example_nic.id,
  ]
  tags       = local.common_tags
  depends_on = [azurerm_network_interface_security_group_association.example_nic_nsg_assoc]
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
  connection {
    type        = "ssh"
    host        = self.public_ip_address
    user        = local.username
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    timeout     = "5m"
  }
  # 4. The File Provisioner (relative path)
  provisioner "file" {
    source      = "testing.txt"        # Path on your local machine
    destination = "/tmp/relative2.txt" # Path on the remote Azure VM
  }
  # 4. The File Provisioner (absolute path)
  provisioner "file" {
    source      = "C:\\1 - Terraform Learning\\Freecodecamp_Terraform\\010_provisioners\\testing.txt" # Path on your local machine
    destination = "/tmp/absolute.txt"                                                                 # Path on the remote Azure VM
  }
  # 4. The File Provisioner (path.module)
  # path.module = folder this .tf file lives in ("." here, since this is the root module)
  # so this resolves to "./testing.txt" no matter where terraform is run from
  provisioner "file" {
    source      = "${path.module}/testing.txt" # Path on your local machine
    destination = "/tmp/pathmodule.txt"        # Path on the remote Azure VM
  }
  /*
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "uptime",
      "echo 'Hello from Terraform' > /tmp/hello.txt",
      "cat /tmp/hello.txt",
      "cat /tmp/relative.txt",
      "cat /tmp/absolute.txt",
      "cat /tmp/pathmodule.txt",
    ]
  }*/
}

resource "null_resource" "example_null" {
  triggers = {
    vm_id       = azurerm_linux_virtual_machine.example_vm.id
    script_hash = filemd5("${path.module}/testing.txt")
  }
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.example_vm.public_ip_address
    user        = local.username
    private_key = file(pathexpand("~/.ssh/id_rsa"))
  }
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "uptime",
      "echo 'Hello from Terraform' > /tmp/hello.txt",
      "cat /tmp/hello.txt",
      "cat /tmp/relative.txt",
      "cat /tmp/absolute.txt",
      "cat /tmp/pathmodule.txt",
    ]
  }
}

# Terraform 1.4 replacement to null_resource
resource "terraform_data" "configure_vm" {
  triggers_replace = [
    azurerm_linux_virtual_machine.example_vm.id,
    filemd5("${path.module}/testing.txt"),
  ]
  # connection + provisioner same as above
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.example_vm.public_ip_address
    user        = local.username
    private_key = file(pathexpand("~/.ssh/id_rsa"))
  }
  provisioner "remote-exec" {
    inline = [
      "hostname",
      "uptime",
      "echo 'Hello from Terraform' > /tmp/hello.txt",
      "cat /tmp/hello.txt",
      "cat /tmp/relative.txt",
      "cat /tmp/absolute.txt",
      "cat /tmp/pathmodule.txt",
    ]
  }
}

/*
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
  // in practice its better to give different address spaces to different vnets
  // two of the same ip in the same network causes problems
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}
*/
# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "resource_id" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.example_my_resource.id
}

output "public_ip_address" {
  value       = azurerm_linux_virtual_machine.example_vm.public_ip_address
  description = "Public IP address of the VM"
}