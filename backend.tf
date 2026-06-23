# Backend remoto para el state de Terraform.
# Los valores deben apuntar al Resource Group/Storage Account creados a mano
# en la Fase 0 (bootstrap) descrita en README.md — NO son los recursos que
# este código gestiona, para evitar la dependencia circular de que Terraform
# necesite un storage que él mismo todavía no ha creado.
#
# TODO: ajustar resource_group_name y storage_account_name a los nombres
# reales creados en el bootstrap (storage_account_name debe ser único en Azure).
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatemlops"
    container_name       = "tfstate"
    key                  = "mlops-databricks-iac.tfstate"
  }
}
