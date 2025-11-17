resource "random_password" "postgres_admin" {
  length  = 16
  special = false
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = "${var.deployment_name}-psql"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres_version
  delegated_subnet_id           = var.subnet
  private_dns_zone_id           = var.private_dns_zone
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = random_password.postgres_admin.result
  zone                          = var.primary_zone

  storage_mb        = 32768
  storage_tier      = var.storage_tier
  auto_grow_enabled = true

  sku_name = var.sku_name

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  high_availability {
    mode                      = var.high_availability_mode
    standby_availability_zone = var.secondary_zone
  }

  maintenance_window {
    day_of_week  = var.maintenance_window["day_of_week"]
    start_hour   = var.maintenance_window["start_hour"]
    start_minute = var.maintenance_window["start_minute"]
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
