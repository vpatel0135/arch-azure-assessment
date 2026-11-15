provider "azurerm" {
  features {
    # No queue/static website features are used. Keep provisioning on ARM APIs
    # so private-only Storage does not require a private Terraform runner.
    storage {
      data_plane_available = false
    }
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# ARM control-plane creation of the container avoids storage account keys
# and does not require the Terraform runner to reach the private Blob endpoint.
provider "azapi" {
  subscription_id = var.subscription_id
}
