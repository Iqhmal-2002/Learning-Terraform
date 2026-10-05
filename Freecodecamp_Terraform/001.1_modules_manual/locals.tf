# locals.tf has the locals for the root module. It defines the name_prefix and common_tags locals.
locals {
  name_prefix = "${var.project}-${var.env}"   # "azlab-dev"
  common_tags = {
    environment = var.env
    owner       = "iqhmal"
    managed_by  = "terraform"
  }
}