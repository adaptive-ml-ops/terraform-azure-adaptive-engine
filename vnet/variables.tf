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

  validation {
    condition     = can(cidrhost(var.vnet_subnet, 0))
    error_message = "The vnet_subnet must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.vnet_subnet)[1]) <= 14
    error_message = "The vnet_subnet must have a prefix length of /14 or larger (e.g., /14, /13, /12) to accommodate subnet carving."
  }
}
