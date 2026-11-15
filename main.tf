locals {
  name_prefix = "${var.environment}-${var.workload}"
  # Stable across redeployments; avoids hard-coded global resource names.
  suffix = substr(sha256("${var.subscription_id}-${local.name_prefix}"), 0, 8)
  tags = {
    environment = var.environment
    application = var.workload
    owner       = var.owner
    costCenter  = var.cost_center
    managedBy   = "terraform"
  }
}
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  tags                = local.tags
  address_space       = var.vnet_address_space
}
module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  tags                = local.tags
  endpoint_subnet_id  = module.networking.endpoint_subnet_id
  dns_zone_ids        = module.networking.monitor_dns_zone_ids
}
module "application" {
  source                     = "./modules/application"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  name_prefix                = local.name_prefix
  tags                       = local.tags
  suffix                     = local.suffix
  integration_subnet_id      = module.networking.integration_subnet_id
  endpoint_subnet_id         = module.networking.endpoint_subnet_id
  dns_zone_ids               = module.networking.application_dns_zone_ids
  workspace_id               = module.monitoring.workspace_id
  insights_connection_string = module.monitoring.connection_string
}
module "access" {
  source                  = "./modules/access"
  resource_group_id       = azurerm_resource_group.this.id
  subscription_id         = var.subscription_id
  principal_id            = module.application.principal_id
  vault_id                = module.application.vault_id
  container_id            = module.application.container_id
  insights_id             = module.monitoring.insights_id
  readers_group_object_id = var.readers_group_object_id
  writers_group_object_id = var.writers_group_object_id
  pim_start_date_time     = var.pim_start_date_time
}
