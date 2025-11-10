output "client_id" {
  description = "The application (client) ID of the Azure AD application"
  value       = azuread_application.this.client_id
}

output "client_secret" {
  description = "The client secret for the Azure AD application"
  value       = azuread_application_password.this.value
  sensitive   = true
}

output "tenant_id" {
  description = "The Azure AD tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "issuer_url" {
  description = "The OpenID Connect issuer URL for Azure AD"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
}
