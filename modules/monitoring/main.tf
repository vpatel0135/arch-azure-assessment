resource "azurerm_log_analytics_workspace" "this" {
  name                         = "law-${var.name_prefix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku                          = "PerGB2018"
  retention_in_days            = 30
  internet_ingestion_enabled   = false
  internet_query_enabled       = false
  local_authentication_enabled = false
  tags                         = var.tags
}
resource "azurerm_application_insights" "this" {
  name                         = "appi-${var.name_prefix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  workspace_id                 = azurerm_log_analytics_workspace.this.id
  application_type             = "web"
  retention_in_days            = 30
  local_authentication_enabled = false
  internet_ingestion_enabled   = false
  internet_query_enabled       = false
  tags                         = var.tags
}
resource "azurerm_monitor_private_link_scope" "this" {
  name                  = "ampls-${var.name_prefix}"
  resource_group_name   = var.resource_group_name
  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"
  tags                  = var.tags
}
resource "azurerm_monitor_private_link_scoped_service" "workspace" {
  name                = "workspace"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = azurerm_log_analytics_workspace.this.id
}
resource "azurerm_monitor_private_link_scoped_service" "insights" {
  name                = "insights"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = azurerm_application_insights.this.id
}
resource "azurerm_private_endpoint" "monitor" {
  name                = "pe-monitor-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "monitor"
    private_connection_resource_id = azurerm_monitor_private_link_scope.this.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "monitor"
    private_dns_zone_ids = var.dns_zone_ids
  }
  # Azure builds endpoint DNS records from the services already in this scope.
  depends_on = [azurerm_monitor_private_link_scoped_service.workspace, azurerm_monitor_private_link_scoped_service.insights]
}
