# Create a resource group
resource "azurerm_resource_group" "example_my_resource" {
  #name     = "example-resources"
  name      = var.rg_name
  location  = var.location
  tags      = var.tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_my_network" {
  name                = var.vnet_name
  # azurerm_resource_group under here needs the actual name of the resource group
  resource_group_name = azurerm_resource_group.example_my_resource.name
  location            = azurerm_resource_group.example_my_resource.location
  address_space       = var.address_space
  tags                = var.tags
}
