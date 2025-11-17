# Generic Variables

variable "deployment_name" {
  default     = "adaptive"
  description = "Name of the deployment"
  type        = string
}

variable "location" {
  description = "Region of the deployment"
  type        = string
}

variable "hostname" {
  # default     = "https://adaptive.test.com"
  description = "Hostname of the deployment in the format 'https://<url>'"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to created resources"
  type        = map(string)
}

# Network variables

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

# AKS variables

variable "cpu_node_pool_vm_size" {
  default     = "Standard_D16as_v6"
  description = "VM size to use for CPU node pool"
  type        = string
}

variable "gpu_node_pool_vm_size" {
  description = "VM size to use for GPU node pool"
  type        = string
}

variable "gpu_node_count" {
  description = "Number of GPU nodes inside the node pool"
  type        = number
}

variable "aks_azure_logs" {
  default     = false
  description = "Enable logging of AKS pods to Azure Log Analytics workspace"
  type        = bool
}

variable "aks_azure_metrics" {
  default     = false
  description = "Enable metrics export of AKS pods to Azure Monitoring workspace"
  type        = bool
}


# Postgres variables

variable "postgres_version" {
  default     = "17"
  description = "The version of PostgreSQL to use."
  type        = string

  validation {
    condition     = tonumber(var.postgres_version) > 16
    error_message = "The postgres_version must be greater than 16."
  }
}

variable "db_sku_name" {
  default     = "GP_Standard_D4ads_v5"
  description = "The vm class for the Postgres DB."
  type        = string
}

variable "db_storage_tier" {
  default     = "P4"
  description = "The name of storage performance tier for IOPS of the PostgreSQL Flexible Server."
  type        = string
}

variable "db_high_availability_mode" {
  default     = "ZoneRedundant"
  description = "The high availability mode for the PostgreSQL Flexible Server. Possible value are SameZone or ZoneRedundant or None to disable."
  type        = string
}

variable "db_primary_zone" {
  default     = "1"
  description = "Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string

  validation {
    condition     = can(regex("^[1-3]$", var.db_primary_zone))
    error_message = "The db_primary_zone must be a valid Azure availability zone: '1', '2', or '3'."
  }
}

variable "db_secondary_zone" {
  default     = "2"
  description = "Specifies the secondary Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string

  validation {
    condition     = can(regex("^[1-3]$", var.db_secondary_zone))
    error_message = "The db_secondary_zone must be a valid Azure availability zone: '1', '2', or '3'."
  }

  validation {
    condition     = var.db_secondary_zone != var.db_primary_zone
    error_message = "The db_secondary_zone must be different from db_primary_zone for high availability configuration."
  }
}

variable "db_geo_redundant_backup_enabled" {
  default     = true
  description = "Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server."
  type        = bool
}

variable "db_maintenance_window" {
  description = "The maintenance window for the database."
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })

  default = { #Sunday 2-3 AM
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }
}
