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

# MAP: any keys, but every value must be the SAME type (here: string)
variable "locations" {
  type = map(string)
  default = {
    dev  = "eastus"
    prod = "westus"
    staging = 5
  }
}

# OBJECT: a FIXED set of attributes, each with its OWN type
# Try removing "size" or setting size = "big" in the default -> validate fails
variable "vm" {
  type = object({
    name   = string
    size   = number
    public = bool
    disks  = list(string)
  })
  default = {
    name   = "web-vm"
    size   = 2
    public = true
    disks  = ["os", "data"]
  }
}

# MAP OF OBJECTS: map keys are free (dev, prod, ...), each value has the object shape
variable "environments" {
  type = map(object({
    location = string
    owner    = string
    optional = optional(string, "unassigned") # optional attribute with default value
  }))
  default = {
    dev = {
      location = "eastus"
      owner    = "iqhmal"
    }
    prod = {
      location = "westus"
      owner    = "ops-team"
    }
    staging = {
      location = "southeastasia"
      owner    = "ops-team"
    }
  }
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------
locals {
  # LIST: ordered, looked up by position [0], [1], ...
  regions = ["eastus", "westus", "southeastasia"]
}

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------

# for_each over a map of objects:
#   each.key   -> "dev" / "prod"            (the map key)
#   each.value -> { location = ..., owner = ... }  (an object)
resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  name     = "maps-objects-${each.key}"
  location = each.value.location
  tags = {
    environment = each.key
    owner       = each.value.owner
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

# --- List: lookup by position ---
output "list_second_item" {
  value = local.regions[1] # "westus"
}

# --- Map: lookup by key ---
output "map_prod_location" {
  value = var.locations["prod"] # "westus"
}

output "map_keys" {
  value = keys(var.locations) # ["dev", "prod"]
}

output "map_values" {
  value = values(var.locations) # ["eastus", "westus"]
}

# --- Object: lookup by attribute name ---
output "object_size" {
  value = var.vm.size # 2 (a number, not a string)
}

output "object_first_disk" {
  value = var.vm.disks[0] # object attribute that is a list -> "os"
}

# --- Map of objects: key first, then attribute ---
output "map_of_objects_prod_owner" {
  value = var.environments["prod"].owner # "ops-team"
}

# --- Resource created with for_each is a MAP of OBJECTS too ---
output "rg_ids_list" {
  value = values(azurerm_resource_group.rg)[*].id # list, keys lost
}

output "rg_ids_map" {
  value = { for k, rg in azurerm_resource_group.rg : k => rg.id } # map, keys kept
}
