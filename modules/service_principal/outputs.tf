output "client_id" {
  value = azuread_application.this.client_id
}

output "object_id" {
  value = azuread_service_principal.this.object_id
}

output "client_secret" {
  value     = var.create_secret ? azuread_service_principal_password.this[0].value : null
  sensitive = true
}
