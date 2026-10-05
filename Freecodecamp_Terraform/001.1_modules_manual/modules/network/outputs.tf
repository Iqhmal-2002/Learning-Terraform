# Outputs ("return values") of this module. The root reads these
# as module.network.<output_name>

output "resource_group_id" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.example_my_resource.id
}

output "resource_group_name" {
  description = "Name of the resource group created"
  value       = azurerm_resource_group.example_my_resource.name
}

output "vnet_id" {
  description = "ID of the virtual network created"
  value       = azurerm_virtual_network.example_my_network.id
}
