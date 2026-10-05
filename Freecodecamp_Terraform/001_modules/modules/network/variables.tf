# Inputs ("parameters") for this module. The root fills these in
# through its module "network" { ... } block.

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for all resources"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "address_space" {
  type        = list(string)
  description = "CIDR ranges for the virtual network"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource"
  default     = {}
}
