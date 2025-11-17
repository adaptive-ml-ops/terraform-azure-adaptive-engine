resource "azurerm_log_analytics_workspace" "this" {
  count = var.aks_azure_logs ? 1 : 0

  name                = "${var.deployment_name}-oms"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "logs_dcr" {
  count = var.aks_azure_logs ? 1 : 0

  name                = "${var.deployment_name}-logs-dcr"
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this[0].id
      name                  = "ciworkspace"
    }
  }

  data_flow {
    streams = ["Microsoft-ContainerLog",
      "Microsoft-ContainerLogV2",
      "Microsoft-KubeEvents",
      "Microsoft-KubePodInventory",
      "Microsoft-KubeNodeInventory",
      "Microsoft-KubePVInventory",
      "Microsoft-KubeServices",
      "Microsoft-KubeMonAgentEvents",
      "Microsoft-InsightsMetrics",
      "Microsoft-ContainerInventory",
      "Microsoft-ContainerNodeInventory",
      "Microsoft-Perf"
    ]
    destinations = ["ciworkspace"]
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["ciworkspace"]
  }

  data_sources {
    extension {
      streams = ["Microsoft-ContainerLog",
        "Microsoft-ContainerLogV2",
        "Microsoft-KubeEvents",
        "Microsoft-KubePodInventory",
        "Microsoft-KubeNodeInventory",
        "Microsoft-KubePVInventory",
        "Microsoft-KubeServices",
        "Microsoft-KubeMonAgentEvents",
        "Microsoft-InsightsMetrics",
        "Microsoft-ContainerInventory",
        "Microsoft-ContainerNodeInventory",
        "Microsoft-Perf"
      ]
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        "dataCollectionSettings" : {
          "interval" : "1m"
          "namespaceFilteringMode" : "Off"
          "namespaces" : []
          "enableContainerLogV2" : true
        }
      })
      name = "${var.deployment_name}-logs-dcra"
    }
  }

  description = "DCR for Azure Monitor Container Insights"
}

resource "azurerm_monitor_data_collection_rule_association" "logs_dcra" {
  count = var.aks_azure_logs ? 1 : 0

  name                    = "${var.deployment_name}-logs-dcra"
  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.logs_dcr[0].id
  description             = "Association of container insights data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}
