variable "deployment_name" {
  default     = "adaptive"
  type        = string
  description = "Name of the deployment"
}

variable "location" {
  type        = string
  description = "Region of the deployment"
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use."
  type        = string
  default     = "17"

  validation {
    condition     = tonumber(var.postgres_version) > 16
    error_message = "The postgres_version must be greater than 16."
  }
}

variable "hostname" {
  description = "Hostname of the deployment in the format 'https://<url>'"
  type        = string
  # default     = "https://adaptive.test.com"
}

variable "db_sku_name" {
  description = "The vm class for the Postgres DB."
  type        = string
  default     = "GP_Standard_D4ads_v5"
}



variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "cidr_vnet" {
  description = "CIDR to use for the VNET"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_vnet, 0))
    error_message = "The cidr_vnet must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.cidr_vnet)[1]) <= 14
    error_message = "The cidr_vnet must have a prefix length of /14 or larger (e.g., /14, /13, /12) to accommodate subnet carving."
  }
}

variable "cpu_node_pool_vm_size" {
  description = "VM size to use for CPU node pool"
  type        = string
  default     = "Standard_D16as_v6"
}

variable "gpu_node_pool_vm_size" {
  description = "VM size to use for GPU node pool"
  type        = string
}

variable "gpu_node_count" {
  description = "Number of GPU nodes inside the node pool"
  type        = number
}
