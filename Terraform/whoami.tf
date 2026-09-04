data "azurerm_client_config" "current" {}

output "current_subscription" {
  value = data.azurerm_client_config.current.subscription_id
  sensitive = true
}

output "current_tenant" {
  value = data.azurerm_client_config.current.tenant_id
  sensitive = true
}