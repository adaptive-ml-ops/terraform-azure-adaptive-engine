resource "azurerm_resource_group" "this" {
  name     = var.deployment_name
  location = var.location

  tags = var.tags
}

module "vnet" {
  source = "./vnet"

  vnet_subnet = var.cidr_vnet

  resource_group_name = azurerm_resource_group.this.name
  deployment_name     = var.deployment_name
  location            = var.location
  tags                = var.tags
}

module "aks" {
  source = "./aks"

  resource_group_name = azurerm_resource_group.this.name
  deployment_name     = var.deployment_name
  location            = var.location
  tags                = var.tags

  subnet = module.vnet.k8s_subnet

  cpu_node_pool_vm_size = var.cpu_node_pool_vm_size
  gpu_node_pool_vm_size = var.gpu_node_pool_vm_size
  gpu_node_count        = var.gpu_node_count

  aks_azure_logs     = var.aks_azure_logs
  aks_azure_metrics  = var.aks_azure_metrics
  log_retention_days = var.aks_log_retention_days

  depends_on = [module.vnet]
}

module "postgres" {
  source = "./postgres"

  resource_group_name = azurerm_resource_group.this.name
  deployment_name     = var.deployment_name

  subnet           = module.vnet.postgres_subnet
  private_dns_zone = module.vnet.postgres_dns_zone

  sku_name           = var.db_sku_name
  postgres_version   = var.postgres_version
  maintenance_window = var.db_maintenance_window
  storage_tier       = var.db_storage_tier

  geo_redundant_backup_enabled = var.db_geo_redundant_backup_enabled
  high_availability_mode       = var.db_high_availability_mode

  primary_zone   = var.db_primary_zone
  secondary_zone = var.db_secondary_zone

  location = var.location
  tags     = var.tags

  depends_on = [module.vnet]
}

module "redis" {
  source = "./redis"

  resource_group_name = azurerm_resource_group.this.name
  deployment_name     = var.deployment_name

  subnet  = module.vnet.redis_subnet
  vnet_id = module.vnet.vnet_id

  sku_name                  = var.redis_sku_name
  high_availability_enabled = var.redis_high_availability_enabled
  public_network_access     = var.redis_public_network_access
  clustering_policy         = var.redis_clustering_policy
  eviction_policy           = var.redis_eviction_policy

  location = var.location
  tags     = var.tags

  depends_on = [module.vnet]
}

module "oidc" {
  source = "./oidc_app"

  deployment_name = var.deployment_name
  hostname        = var.hostname
}
