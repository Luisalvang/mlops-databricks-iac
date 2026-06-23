terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# ── Resource Group compartido por los 3 ambientes ──────────────────────────
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

# ── Storage Account compartido (ADLS Gen2) ─────────────────────────────────
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # ADLS Gen2 — requerido para Unity Catalog
}

resource "azurerm_storage_container" "this" {
  for_each              = toset(var.storage_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# ── Access Connector: identidad managed para que Unity Catalog acceda al storage ──
resource "azurerm_databricks_access_connector" "this" {
  name                = var.access_connector_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "access_connector_blob" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "access_connector_queue" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

# ── SPN de deploy: único para todo el Resource Group, con Client Secret ────
module "spn_deploy" {
  source        = "./modules/service_principal"
  display_name  = var.spn_deploy_name
  create_secret = true
}

resource "azurerm_role_assignment" "spn_deploy_contributor" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = module.spn_deploy.object_id
}

# ── Databricks Workspaces por ambiente ──────────────────────────────────────
module "databricks_workspace" {
  source   = "./modules/databricks_workspace"
  for_each = var.environments

  name                = each.value.workspace_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

# ── SPN run_as por ambiente: solo identidad, sin Client Secret ─────────────
module "spn_run" {
  source   = "./modules/service_principal"
  for_each = var.environments

  display_name  = each.value.spn_run_name
  create_secret = false
}
