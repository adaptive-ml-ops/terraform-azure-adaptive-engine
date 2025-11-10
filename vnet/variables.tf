# Generic Variables

variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Region of the deployment"
  type        = string
}


variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
}

# VNET Specific

variable "vnet_subnet" {
  description = "CIDR to use for the vnet format x.x.x.x/x "
  type        = string

  # TODO Validation that its at least 14
}
