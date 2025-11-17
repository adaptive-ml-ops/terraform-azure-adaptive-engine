output "postgres_connection_string" {
  description = "PostgreSQL connection string for the adaptive database"
  value       = module.postgres.connection_string
  sensitive   = true
}

output "oidc_auth_config" {
  description = "OIDC authentication configuration for Azure AD"
  value = yamlencode({
    name                   = "Azure"
    key                    = "azure"
    issuer_url             = module.oidc.issuer_url
    client_id              = module.oidc.client_id
    client_secret          = module.oidc.client_secret
    scopes                 = ["email", "profile"]
    pkce                   = true
    allow_sign_up          = true
    require_email_verified = false
  })
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}
