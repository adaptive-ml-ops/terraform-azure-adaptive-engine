resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.deployment_name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.deployment_name}aks"

  default_node_pool {
    name                 = "default"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 10
    os_sku               = "Ubuntu"
    vm_size              = var.cpu_node_pool_vm_size
    vnet_subnet_id       = var.subnet
    tags                 = var.tags

    temporary_name_for_rotation = "default2"

    upgrade_settings {
      drain_timeout_in_minutes      = 20
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin_mode = "overlay"
    network_plugin      = "azure"
    network_policy      = var.network_policy
  }

  web_app_routing {
    dns_zone_ids = []
  }

  tags = var.tags
}

# Gpu Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "gpu_compute" {
  name                  = "gpunodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.gpu_node_pool_vm_size
  vnet_subnet_id        = var.subnet
  gpu_driver            = "Install"
  auto_scaling_enabled  = true
  min_count             = var.gpu_node_count
  max_count             = var.gpu_node_count

  temporary_name_for_rotation = "gpunodepool2"

  node_labels = {
    nodepool = "gpu"
  }
  node_taints = ["nvidia.com/gpu=value:NoSchedule"]

  upgrade_settings {
    drain_timeout_in_minutes      = 20
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }

  tags = var.tags
}
