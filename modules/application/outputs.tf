output "principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "vault_id" {
  value = azurerm_key_vault.this.id
}

output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "container_id" {
  value = azapi_resource.documents.id
}

output "blob_service_url" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "web_app_name" {
  value = azurerm_linux_web_app.this.name
}

output "hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}
