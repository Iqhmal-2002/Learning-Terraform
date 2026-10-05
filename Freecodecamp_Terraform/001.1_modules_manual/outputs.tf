# outputs.tf has the outputs for the root module. It outputs the resource group ID of the first network module.
# this output uses the output from the network module, which is defined in modules/network/outputs.tf
output "instance_id" {
  description = "ID of the resource group created"
  value       = module.network.resource_group_id
}
