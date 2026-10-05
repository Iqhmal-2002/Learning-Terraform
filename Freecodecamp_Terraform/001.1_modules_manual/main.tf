# main.tf has what gets built in the root module. It calls the network module twice, creating two virtual networks in two different resource groups.
module "network" {
  source = "./modules/network"

  rg_name       = var.instance_name
  location      = "westus2"
  vnet_name     = "example-network"
  address_space = ["10.0.0.0/16"]
  tags          = local.common_tags
}

module "network2" {
  source = "./modules/network"

  rg_name       = "rg2"
  location      = "westus2"
  #vnet name only need to be unique within the resource group, so we can use the same name as the first module
  vnet_name     = "example-network"
  address_space = ["10.0.0.0/16"]
  tags          = local.common_tags
}



