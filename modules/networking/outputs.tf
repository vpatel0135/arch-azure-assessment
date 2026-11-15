output "integration_subnet_id" {
  value = azurerm_subnet.integration.id
}

output "endpoint_subnet_id" {
  value = azurerm_subnet.endpoints.id
}

output "application_dns_zone_ids" {
  value = { for key, name in local.application_zones : key => azurerm_private_dns_zone.this[name].id }
}

output "monitor_dns_zone_ids" {
  value = [for name in setunion(local.monitor_zones, toset([local.application_zones.blob])) : azurerm_private_dns_zone.this[name].id]
}
