resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.deployment_name}-redis-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_managed_redis" "this" {
  name                = "${var.deployment_name}-redis"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name

  high_availability_enabled = var.high_availability_enabled

  default_database {
    access_keys_authentication_enabled          = true
    client_protocol                             = "Encrypted"
    clustering_policy                           = var.clustering_policy
    eviction_policy                             = var.eviction_policy
    persistence_redis_database_backup_frequency = var.persistence_rdb_backup_frequency
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  name                = "${var.deployment_name}-redis-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet

  private_service_connection {
    name                           = "${var.deployment_name}-redis-psc"
    private_connection_resource_id = azurerm_managed_redis.this.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.deployment_name}-redis-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}
