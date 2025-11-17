resource "azurerm_monitor_workspace" "amw" {
  count = var.aks_azure_metrics ? 1 : 0

  name = "${var.deployment_name}-amw"

  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  count               = var.aks_azure_metrics ? 1 : 0
  name                = "${var.deployment_name}-mse"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
}


resource "azurerm_monitor_data_collection_rule" "metrics_dcr" {
  count = var.aks_azure_metrics ? 1 : 0

  name                        = "${var.deployment_name}-metrics-dcr"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce[0].id
  kind                        = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.amw[0].id
      name               = "MonitoringAccount1"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }

  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.dce[0]
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "metrics_dcra" {
  count = var.aks_azure_metrics ? 1 : 0

  name = "${var.deployment_name}-metrics-dcra"

  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.metrics_dcr[0].id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.metrics_dcr
  ]
}
