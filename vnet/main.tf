resource "azurerm_virtual_network" "this" {
  name                = "${var.deployment_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_subnet]

  tags = var.tags
}

# Subnet For postgresql DB
resource "azurerm_subnet" "postgres" {
  name                 = "${var.deployment_name}-postgres-sn"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.postgres_subnet]

  service_endpoints = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.deployment_name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.deployment_name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.this.id
  resource_group_name   = var.resource_group_name
  depends_on            = [azurerm_subnet.postgres]
}

# Subnet For AKS
resource "azurerm_subnet" "aks" {
  name                 = "${var.deployment_name}-aks-sn"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [local.k8s_subnet]
}
