resource_group_name = "rg-devops-zmod-001"

# TODO: confirmar la región real de Azure antes del primer apply
location = "eastus2"

storage_account_name = "adlszonmodmlops"
storage_containers   = ["experimentacion", "validacion", "ejecucion"]

access_connector_name = "ac-zmod-001"

spn_deploy_name = "spn-deploy-devops-001"

environments = {
  exp = {
    workspace_name = "adbk-zmod-exp-001"
    spn_run_name   = "spn-zmod-adb-exp-001"
  }
  val = {
    workspace_name = "adbk-zmod-val-001"
    spn_run_name   = "spn-zmod-adb-val-001"
  }
  eje = {
    workspace_name = "adbk-zmod-eje-001"
    spn_run_name   = "spn-zmod-adb-eje-001"
  }
}
