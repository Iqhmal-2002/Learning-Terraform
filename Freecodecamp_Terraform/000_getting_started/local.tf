locals {
  name_prefix = "${var.project}-${var.env}"   # "azlab-dev"
  common_tags = {
    environment = var.env
    owner       = "iqhmal"
    managed_by  = "terraform"
  }
}