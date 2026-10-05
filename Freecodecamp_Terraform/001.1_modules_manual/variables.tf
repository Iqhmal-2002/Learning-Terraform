# Variables.tf has the variables for the root module. It defines the instance_name, env, and project variables.
variable "instance_name" {
  type = string
  default = "azlab-dev"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "azlab"
}