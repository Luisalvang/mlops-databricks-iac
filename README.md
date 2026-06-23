# mlops-databricks-iac

Infraestructura Azure del proyecto MLOps gestionada con Terraform: un Resource Group
compartido por los 3 ambientes (DEV/QA/PROD), con un Storage Account y un Databricks
Access Connector también compartidos, y un Databricks Workspace + SPN de `run_as` por
ambiente.

## Recursos gestionados

| Recurso | Nombre | Alcance |
|---|---|---|
| Resource Group | `rg-devops-zmod-001` | compartido |
| Storage Account (ADLS Gen2) | `adlszonmodmlops` | compartido |
| Containers | `experimentacion` / `validacion` / `ejecucion` | uno por ambiente |
| Databricks Access Connector | `ac-zmod-001` | compartido |
| SPN de deploy (con Client Secret) | `spn-deploy-devops-001` | compartido |
| Databricks Workspace | `adbk-zmod-{exp,val,eje}-001` | por ambiente |
| SPN run_as (sin Client Secret) | `spn-zmod-adb-{exp,val,eje}-001` | por ambiente |

Permisos asignados por este código:
- `ac-zmod-001` → `Storage Blob Data Contributor` + `Storage Queue Data Contributor` sobre `adlszonmodmlops`
- `spn-deploy-devops-001` → `Contributor` sobre `rg-devops-zmod-001`

## Fase 0 — Bootstrap manual (una sola vez, antes de correr Terraform)

Terraform no puede crear las credenciales con las que él mismo se autentica, y
`spn-deploy-devops-001` es uno de los recursos que este código crea. Antes del primer
`terraform apply` hace falta, fuera de Terraform:

1. **Crear un SPN bootstrap** (Azure Portal o `az cli`) con:
   - Rol **Contributor** sobre la subscription (o al menos sobre el scope donde se
     creará `rg-devops-zmod-001`)
   - Rol **Application Administrator** en Azure AD (necesario para crear los 4 SPN
     vía el provider `azuread`: `spn-deploy-devops-001` + los 3 `spn-zmod-adb-*-001`)

   Este SPN bootstrap es el que GitHub Actions usará para correr Terraform. Se
   recomienda mantenerlo como identidad permanente del pipeline (no migrar a
   `spn-deploy-devops-001` después de la primera corrida, porque ese solo tiene
   Contributor sobre el Resource Group, no Application Administrator).

2. **Crear el storage del remote state de Terraform**, separado de
   `rg-devops-zmod-001` para evitar dependencia circular:
   ```bash
   az group create --name rg-tfstate --location <region>
   az storage account create --name sttfstatemlops --resource-group rg-tfstate --sku Standard_LRS
   az storage container create --name tfstate --account-name sttfstatemlops
   ```
   Ajustar los nombres reales en [backend.tf](backend.tf) si difieren de los de ejemplo.

3. **Guardar en GitHub Secrets** de este repo las credenciales del SPN bootstrap:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_TENANT_ID`
   - `ARM_SUBSCRIPTION_ID`

4. Confirmar/ajustar `location` en [terraform.tfvars](terraform.tfvars) (región real
   de Azure — queda con un valor placeholder hasta confirmarlo).

## Uso local

```bash
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Requiere las mismas 4 variables de entorno (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`,
`ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`) exportadas localmente con las credenciales del
SPN bootstrap.

## CI/CD

- **`pr.yml`** — en cada PR a `main`: `terraform fmt -check` + `validate` + `plan`
- **`deploy.yml`** — `workflow_dispatch` manual (o push a `main`): `terraform apply`.
  Usa el [environment de GitHub](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
  `production`, configurable con reglas de aprobación manual antes de aplicar.

## Después del primer apply

`terraform output` expone (marcado `sensitive`) el `client_secret` de
`spn-deploy-devops-001` y los `client_id` de los 3 SPN `run_as`. Estos valores
reemplazan en `mlops-deploy-models-dab`:
- Los 3 `DATABRICKS_CLIENT_ID_*` / `DATABRICKS_CLIENT_SECRET_*` → todos pasan a usar
  el único `spn-deploy-devops-001`
- Los 3 `DATABRICKS_RUN_CLIENT_ID_*` → pasan a ser los `client_id` de
  `spn-zmod-adb-{exp,val,eje}-001`

Ver `SETUP.md` de ese repo para la lista completa de secrets a actualizar.
