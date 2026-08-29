variable "resource_group_name" {
  description = "Nombre del Resource Group compartido para los 3 ambientes"
  type        = string
}

variable "location" {
  description = "Región de Azure donde se crean todos los recursos"
  type        = string
}

variable "storage_account_name" {
  description = "Nombre del Storage Account compartido (ADLS Gen2) — solo minúsculas/números, único en todo Azure"
  type        = string
}

variable "storage_containers" {
  description = "Containers a crear dentro del Storage Account (uno por ambiente)"
  type        = list(string)
}

variable "access_connector_name" {
  description = "Nombre del Databricks Access Connector compartido"
  type        = string
}

variable "spn_deploy_name" {
  description = "Nombre del SPN único de deploy (Contributor sobre el Resource Group)"
  type        = string
}

variable "environments" {
  description = "Mapa de ambientes: nombre del Databricks Workspace y del SPN run_as por ambiente"
  type = map(object({
    workspace_name = string
    spn_run_name   = string
  }))
}
