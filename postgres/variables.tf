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

# Postgres Variables

variable "postgres_version" {
  description = "Version of postgresql to use"
  type        = string

  validation {
    condition     = tonumber(var.postgres_version) > 16
    error_message = "The postgres_version must be greater than 16."
  }
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "adaptive"
}

variable "sku_name" {
  description = "The vm class for the Postgres DB."
  type        = string
}

variable "storage_tier" {
  default     = "P4"
  description = "The name of storage performance tier for IOPS of the PostgreSQL Flexible Server."
  type        = string
}

variable "subnet" {
  description = "ID of the Subnet to use"
  type        = string

  # TODO add validation
}

variable "private_dns_zone" {
  description = "ID of the zone to use"
  type        = string

  # TODO add validation
}


variable "high_availability_mode" {
  description = "The high availability mode for the PostgreSQL Flexible Server. Possible value are SameZone or ZoneRedundant."
  type        = string
}

variable "geo_redundant_backup_enabled" {
  description = "Is Geo-Redundant backup enabled on the PostgreSQL Flexible Server."
  type        = bool
}

variable "maintenance_window" {
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

variable "backup_retention_days" {
  description = "Backup retention days (7-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 7 and 35."
  }
}

variable "primary_zone" {
  description = "Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
}

variable "secondary_zone" {
  description = "Specifies the secondary Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
}
