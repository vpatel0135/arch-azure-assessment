# Private Azure Web Application Platform

**Chosen tool: Terraform (AzureRM and AzAPI).** Modular, declarative configuration keeps the platform reusable and supports review through Terraform plans. This provisions infrastructure for an internal .NET 10 application; application code is outside scope.

## Architecture and generated code summary

| Module | Resources and purpose |
| --- | --- |
| `networking` | VNet, delegated App Service integration subnet, private endpoint subnet, seven private DNS zones and VNet links |
| `application` | Linux P1v3 plan, .NET 10 Web App, one user-assigned identity, RBAC Key Vault, Storage account/documents container, three private endpoints and resource diagnostics |
| `monitoring` | Workspace-based Application Insights, Log Analytics, Azure Monitor Private Link Scope, service links and a monitoring private endpoint |
| `access` | Application data permissions, standing Reader assignment, eligible Contributor assignment and PIM activation policy |

Root `main.tf` creates the resource group and connects the modules. `providers.tf` configures Azure access; `versions.tf` and the lock file fix provider versions. `variables.tf` and `terraform.tfvars.example` define inputs and placeholder examples. `outputs.tf` exposes the app hostname, service URLs, identity client ID, resource group and workspace name.

**Connectivity:** inbound App Service Private Link; outbound VNet integration to private Vault, Blob and telemetry endpoints. Private DNS resolves service hostnames to private IPs. Public network access is disabled.

**Identity:** one shared identity has Secrets User on Vault, Blob Data Contributor on the documents container, and Monitoring Metrics Publisher on Insights. App settings supply its client ID and service URLs; no account keys or passwords are used.

**Governance:** COMPANYA_READERS has standing Reader. COMPANYA_WRITERS has 90-day Contributor eligibility, with MFA, justification and four-hour maximum activation; no standing Contributor or approval stage.

**Diagnostics:** supported resource log/metric categories go to the workspace through Azure's private diagnostic-delivery channel. Application telemetry uses Azure Monitor Private Link.

## Assumptions and limitations

See [ASSUMPTIONS.md](ASSUMPTIONS.md) for region, SKUs, addressing, identity, private access, retention, naming and deployment prerequisites. No Azure resources or application code were deployed. Runtime behavior and redeployment idempotency have not been exercised against Azure.

## Inputs

| Variable | Description / default |
| --- | --- |
| `subscription_id` | Required target subscription |
| `readers_group_object_id` | Required COMPANYA_READERS object ID |
| `writers_group_object_id` | Required COMPANYA_WRITERS object ID; distinct from Readers |
| `pim_start_date_time` | Required fixed UTC eligibility start |
| `location` | `eastus2` |
| `environment` | `dev`; accepts `dev`, `test`, `prod` |
| `workload` | `internalweb`; 2–12 lowercase alphanumeric characters |
| `vnet_address_space` | `10.42.0.0/16`; must not overlap corporate ranges |
| `owner` | `platform-team` |
| `cost_center` | `assessment` |

## Deployment reference

Requires Terraform 1.13.5, Azure CLI and an authorized subscription. The deployer needs resource creation, unrestricted RBAC assignment, eligibility schedule and role management policy permissions; ordinary Contributor alone is insufficient. Subscription administrators must register `Microsoft.Network`, `Microsoft.Web`, `Microsoft.KeyVault`, `Microsoft.Storage`, `Microsoft.ManagedIdentity`, `Microsoft.Insights` and `Microsoft.OperationalInsights`.

```bash
git clone https://github.com/vpatel0135/arch-azure-assessment.git
cd arch-azure-assessment
cp terraform.tfvars.example terraform.tfvars
# Replace placeholder IDs and set the fixed UTC eligibility start.
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=assessment.tfplan
# Review the plan before creating billable resources.
terraform apply assessment.tfplan
terraform output
```

These commands document deployment; Azure deployment is not required for this submission. Confirm Linux .NET 10 availability and subscription permissions before deployment; allow for RBAC propagation.

## Validation and expected result

Formatting, provider initialization and `terraform validate` passed in [GitHub Actions](https://github.com/vpatel0135/arch-azure-assessment/actions/runs/43773570433). No Azure-connected plan or apply was performed.

**Expected apply result:** one resource group, one VNet/two subnets, seven DNS zones/links, one Linux plan/Web App, one managed identity, one Vault, one Storage account/container, Insights/workspace, one Monitor private-link scope/two service links, four private endpoints, five diagnostic settings, four standing RBAC assignments, and one PIM policy/eligible assignment. This description is provided in place of an executed plan.

## AI assistance

AI tooling generated all Terraform code, the validation workflow and documentation under my direction. I guided the requirements interpretation, architecture, security decisions and end-to-end workflow. The generated implementation covers the four modules and supporting root configuration summarized above.
