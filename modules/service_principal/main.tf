resource "azuread_application" "this" {
  display_name = var.display_name
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_service_principal_password" "this" {
  count                = var.create_secret ? 1 : 0
  service_principal_id = azuread_service_principal.this.id
}
