output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
output "web_app_name" {
  value = module.application.web_app_name
}
output "web_app_url" {
  value = "https://${module.application.hostname}"
}
output "key_vault_uri" {
  value = module.application.vault_uri
}
output "blob_service_url" {
  value = module.application.blob_service_url
}
output "identity_client_id" {
  value = module.application.client_id
}
output "workspace_name" {
  value = module.monitoring.workspace_name
}
