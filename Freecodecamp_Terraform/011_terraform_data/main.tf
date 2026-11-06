# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------
variable "trigger_value" {
  type    = string
  default = "v1"
}

# ---------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------

resource "null_resource" "example_null" {
  triggers = {
    trigger_value = var.trigger_value
    script_hash   = filemd5("${path.module}/testing.txt")
  }
  provisioner "local-exec" {
    command = "echo null_resource ran with ${var.trigger_value}"
  }
}

# Terraform 1.4 replacement to null_resource
resource "terraform_data" "example_data" {
  triggers_replace = [
    var.trigger_value,
    filemd5("${path.module}/testing.txt")
  ]
  provisioner "local-exec" {
    command = "echo terraform_data ran with ${var.trigger_value}"
  }
}