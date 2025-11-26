output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "k8s_subnet" {
  value = azurerm_subnet.aks.id
}

output "postgres_subnet" {
  value = azurerm_subnet.postgres.id
}

output "postgres_dns_zone" {
  value = azurerm_private_dns_zone.postgres.id
}

output "redis_subnet" {
  value = azurerm_subnet.redis.id
}
