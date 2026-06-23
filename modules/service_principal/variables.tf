variable "display_name" {
  description = "Nombre del Service Principal (App Registration) en Azure AD"
  type        = string
}

variable "create_secret" {
  description = "Si es true, genera un Client Secret. Usar solo para SPN que necesitan autenticarse por sí mismos (ej. SPN de deploy); los SPN de run_as no lo necesitan."
  type        = bool
  default     = false
}
