output "server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_id" {
  description = "The ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "database_name" {
  description = "The name of the database"
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "administrator_login" {
  description = "The administrator login name"
  value       = azurerm_postgresql_flexible_server.this.administrator_login
  sensitive   = true
}

output "administrator_password" {
  description = "The administrator password"
  value       = azurerm_postgresql_flexible_server.this.administrator_password
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${azurerm_postgresql_flexible_server.this.administrator_login}:${azurerm_postgresql_flexible_server.this.administrator_password}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${azurerm_postgresql_flexible_server_database.this.name}?sslmode=require"
  sensitive   = true
}
