output "redis_id" {
  description = "The ID of the Managed Redis instance"
  value       = azurerm_managed_redis.this.id
}

output "hostname" {
  description = "The hostname of the Managed Redis instance"
  value       = azurerm_managed_redis.this.hostname
}

output "port" {
  description = "The port of the default database"
  value       = try(azurerm_managed_redis.this.default_database[0].port, 10000)
}

output "primary_access_key" {
  description = "The primary access key for the Managed Redis instance"
  value       = try(azurerm_managed_redis.this.default_database[0].primary_access_key, null)
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Managed Redis instance"
  value       = try(azurerm_managed_redis.this.default_database[0].secondary_access_key, null)
  sensitive   = true
}

output "connection_string" {
  description = "Redis connection string (primary)"
  value       = "rediss://:${try(azurerm_managed_redis.this.default_database[0].primary_access_key, "")}@${azurerm_managed_redis.this.hostname}:${try(azurerm_managed_redis.this.default_database[0].port, 10000)}/0"
  sensitive   = true
}
