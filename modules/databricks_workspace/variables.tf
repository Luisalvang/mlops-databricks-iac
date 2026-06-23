variable "name" {
  description = "Nombre del Databricks Workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group donde se crea el workspace"
  type        = string
}

variable "location" {
  description = "Región de Azure del workspace"
  type        = string
}

variable "sku" {
  description = "SKU del workspace (premium requerido para Unity Catalog)"
  type        = string
  default     = "premium"
}

variable "tags" {
  description = "Tags a aplicar al workspace"
  type        = map(string)
  default     = {}
}
