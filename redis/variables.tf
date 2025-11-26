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

# Redis Variables

variable "sku_name" {
  description = "The SKU for the Managed Redis instance. Examples: Balanced_B3, MemoryOptimized_M10, ComputeOptimized_X3, FlashOptimized_A250."
  type        = string
  default     = "Balanced_B3"

  validation {
    condition     = can(regex("^(Balanced_B|MemoryOptimized_M|ComputeOptimized_X|FlashOptimized_A)", var.sku_name))
    error_message = "The sku_name must be a valid Managed Redis SKU (Balanced_B*, MemoryOptimized_M*, ComputeOptimized_X*, or FlashOptimized_A*)."
  }
}

variable "high_availability_enabled" {
  description = "Whether to enable high availability for the Managed Redis instance."
  type        = bool
  default     = true
}

variable "clustering_policy" {
  description = "Clustering policy. Possible values are EnterpriseCluster, OSSCluster and NoCluster."
  type        = string
  default     = "OSSCluster"

  validation {
    condition     = contains(["EnterpriseCluster", "OSSCluster", "NoCluster"], var.clustering_policy)
    error_message = "The clustering_policy must be one of: EnterpriseCluster, OSSCluster, NoCluster."
  }
}

variable "eviction_policy" {
  description = "Specifies the Redis eviction policy. Possible values are AllKeysLFU, AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileLFU, VolatileTTL, VolatileRandom and NoEviction."
  type        = string
  default     = "VolatileLRU"

  validation {
    condition = contains([
      "AllKeysLFU", "AllKeysLRU", "AllKeysRandom",
      "VolatileLRU", "VolatileLFU", "VolatileTTL", "VolatileRandom",
      "NoEviction"
    ], var.eviction_policy)
    error_message = "The eviction_policy must be a valid Redis eviction policy."
  }
}

variable "subnet" {
  description = "ID of the Subnet to use for private endpoint"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet))
    error_message = "The subnet must be a valid Azure subnet resource ID."
  }
}

variable "vnet_id" {
  description = "ID of the Virtual Network for private DNS zone link"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+$", var.vnet_id))
    error_message = "The vnet_id must be a valid Azure virtual network resource ID."
  }
}

variable "persistence_rdb_backup_frequency" {
  description = "The frequency of Redis Database (RDB) backups. Possible values are 1h, 6h, 12h, or null to disable RDB persistence. Note: Conflicts with geo-replication."
  type        = string
  default     = "1h"

  validation {
    condition     = var.persistence_rdb_backup_frequency == null || contains(["1h", "6h", "12h"], var.persistence_rdb_backup_frequency)
    error_message = "The persistence_rdb_backup_frequency must be either null, 1h, 6h, or 12h."
  }
}
