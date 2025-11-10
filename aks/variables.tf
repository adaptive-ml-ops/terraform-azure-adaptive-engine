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

# K8s Specific

variable "cpu_node_pool_vm_size" {
  description = "Type of VM used for CPU node pool"
  type        = string
}

variable "gpu_node_pool_vm_size" {
  description = "Type of VM used for GPU node pool"
  type        = string
}

variable "gpu_node_count" {
  description = "Number of GPU nodes inside the node pool"
  type        = number
}

variable "subnet" {
  description = "Subnet ID to use for node pools"
  type        = string
}

variable "network_policy" {
  description = "Network policy to use for pod-to-pod traffic control. Options: 'azure' or 'calico'"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'."
  }
}
