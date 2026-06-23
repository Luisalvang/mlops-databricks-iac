output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "databricks_workspace_urls" {
  description = "URL de cada workspace, por ambiente (exp/val/eje)"
  value       = { for k, v in module.databricks_workspace : k => v.workspace_url }
}

output "spn_deploy_client_id" {
  value = module.spn_deploy.client_id
}

output "spn_deploy_client_secret" {
  description = "Client Secret del SPN de deploy — copiar a GitHub Secrets de mlops-deploy-models-dab"
  value       = module.spn_deploy.client_secret
  sensitive   = true
}

output "spn_run_client_ids" {
  description = "Client ID de cada SPN run_as, por ambiente (exp/val/eje) — usar como sp_app_id en databricks.yml"
  value       = { for k, v in module.spn_run : k => v.client_id }
}
