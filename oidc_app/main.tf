resource "azuread_application" "this" {
  display_name = "${var.deployment_name}-app"
  owners       = [data.azuread_client_config.current.object_id]

  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = ["${var.hostname}/api/v1/auth/login/azure/callback"]
  }
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  display_name   = "Client Secret"

}
