output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  value = azurerm_log_analytics_workspace.this.name
}

output "insights_id" {
  value = azurerm_application_insights.this.id
}

output "connection_string" {
  value     = azurerm_application_insights.this.connection_string
  sensitive = true
}
