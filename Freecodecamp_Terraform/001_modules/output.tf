# OLD: the root can no longer see this resource directly, it lives in the module now
# output "instance_id" {
#   description = "ID of the resource group created"
#   value       = azurerm_resource_group.example_my_resource.id
# }

output "instance_id" {
  description = "ID of the resource group created"
  value       = module.network.resource_group_id
}
