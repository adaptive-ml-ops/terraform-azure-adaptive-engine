resource "random_password" "postgres_admin" {
  length  = 16
  special = false
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                          = "${var.deployment_name}-psql"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres_version
  delegated_subnet_id           = var.subnet
  private_dns_zone_id           = var.private_dns_zone
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = random_password.postgres_admin.result
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = var.sku_name

  backup_retention_days = var.backup_retention_days

  auto_grow_enabled = true

  # Maintenance window (Sunday 2-3 AM)
  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
