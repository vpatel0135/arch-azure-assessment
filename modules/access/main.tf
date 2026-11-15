resource "azurerm_role_assignment" "secrets" {
  scope                = var.vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "documents" {
  scope                = var.container_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "telemetry" {
  scope                = var.insights_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "readers" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = var.readers_group_object_id
  principal_type       = "Group"
}
locals {
  # Azure built-in Contributor role GUID; not a customer object/subscription ID.
  contributor_role_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
}
resource "azurerm_role_management_policy" "writers" {
  scope              = var.resource_group_id
  role_definition_id = local.contributor_role_id
  eligible_assignment_rules {
    expiration_required = true
    expire_after        = "P90D"
  }
  activation_rules {
    maximum_duration                   = "PT4H"
    require_multifactor_authentication = true
    require_justification              = true
    require_approval                   = false
  }
}
resource "azurerm_pim_eligible_role_assignment" "writers" {
  scope              = var.resource_group_id
  role_definition_id = local.contributor_role_id
  principal_id       = var.writers_group_object_id
  justification      = "On-demand platform changes; no standing Contributor access."
  schedule {
    start_date_time = var.pim_start_date_time
    expiration {
      duration_days = 90
    }
  }
  depends_on = [azurerm_role_management_policy.writers]
}
