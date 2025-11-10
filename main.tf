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

  depends_on = [module.vnet]
}

module "postgres" {
  source = "./postgres"

  resource_group_name = azurerm_resource_group.this.name
  deployment_name     = var.deployment_name

  subnet           = module.vnet.postgres_subnet
  private_dns_zone = module.vnet.postgres_dns_zone

  sku_name         = var.db_sku_name
  postgres_version = var.postgres_version

  location = var.location
  tags     = var.tags

  depends_on = [module.vnet]
}

module "oidc" {
  source = "./oidc_app"

  deployment_name = var.deployment_name
  hostname        = var.hostname
}
