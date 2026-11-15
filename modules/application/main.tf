data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
resource "azurerm_service_plan" "this" {
  name                = "asp-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "P1v3"
  tags                = var.tags
}
resource "azurerm_key_vault" "this" {
  name                          = "kv-${substr(var.name_prefix, 0, 11)}-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  network_acls {
    default_action = "Deny"
    bypass         = "None"
  }
  tags = var.tags
}
resource "azurerm_storage_account" "this" {
  name                            = "st${substr(replace(var.name_prefix, "-", ""), 0, 14)}${var.suffix}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
  }
  tags = var.tags
}
resource "azapi_resource" "documents" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01"
  name      = "documents"
  parent_id = "${azurerm_storage_account.this.id}/blobServices/default"
  body = {
    properties = {
      publicAccess = "None"
    }
  }
}
resource "azurerm_linux_web_app" "this" {
  name                                           = "app-${var.name_prefix}-${var.suffix}"
  location                                       = var.location
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = azurerm_service_plan.this.id
  https_only                                     = true
  public_network_access_enabled                  = false
  virtual_network_subnet_id                      = var.integration_subnet_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  key_vault_reference_identity_id                = azurerm_user_assigned_identity.this.id
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
  site_config {
    always_on               = true
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
    ftps_state              = "Disabled"
    vnet_route_all_enabled  = true
    application_stack {
      dotnet_version = "10.0"
    }
  }
  app_settings = {
    AZURE_CLIENT_ID                             = azurerm_user_assigned_identity.this.client_id
    KeyVault__VaultUri                          = azurerm_key_vault.this.vault_uri
    Storage__BlobServiceUri                     = azurerm_storage_account.this.primary_blob_endpoint
    Storage__ContainerName                      = azapi_resource.documents.name
    APPLICATIONINSIGHTS_CONNECTION_STRING       = var.insights_connection_string
    APPLICATIONINSIGHTS_AUTHENTICATION_STRING   = "Authorization=AAD;ClientId=${azurerm_user_assigned_identity.this.client_id}"
    ApplicationInsightsAgent_EXTENSION_VERSION  = "~3"
    XDT_MicrosoftApplicationInsights_PreemptSdk = "1"
  }
  tags = var.tags
}

# Each endpoint also creates and maintains its private DNS records.
locals {
  endpoints = {
    vault = { id = azurerm_key_vault.this.id, subresource = "vault" }
    blob  = { id = azurerm_storage_account.this.id, subresource = "blob" }
    web   = { id = azurerm_linux_web_app.this.id, subresource = "sites" }
  }
  diagnostics = {
    web     = azurerm_linux_web_app.this.id
    vault   = azurerm_key_vault.this.id
    blob    = "${azurerm_storage_account.this.id}/blobServices/default"
    storage = azurerm_storage_account.this.id
    plan    = azurerm_service_plan.this.id
  }
}
resource "azurerm_private_endpoint" "this" {
  for_each            = local.endpoints
  name                = "pe-${each.key}-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = each.key
    private_connection_resource_id = each.value.id
    subresource_names              = [each.value.subresource]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = each.key
    private_dns_zone_ids = [var.dns_zone_ids[each.key]]
  }
}
# Discover supported categories instead of assuming every service exports the same logs.
data "azurerm_monitor_diagnostic_categories" "this" {
  for_each    = local.diagnostics
  resource_id = each.value
}
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                   = local.diagnostics
  name                       = "to-workspace"
  target_resource_id         = each.value
  log_analytics_workspace_id = var.workspace_id
  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types)
    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.this[each.key].metrics)
    content {
      category = enabled_metric.value
    }
  }
}
