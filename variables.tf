variable "subscription_id" {
  description = "Subscription to deploy into."
  type        = string
}
variable "location" {
  description = "Single deployment region."
  type        = string
  default     = "eastus2"
}
variable "environment" {
  description = "Environment abbreviation."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Use dev, test, or prod."
  }
}
variable "workload" {
  description = "Short lowercase workload name."
  type        = string
  default     = "internalweb"
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,11}$", var.workload))
    error_message = "Use 2-12 lowercase alphanumeric characters, starting with a letter."
  }
}
variable "owner" {
  description = "Owning team tag."
  type        = string
  default     = "platform-team"
}
variable "cost_center" {
  description = "Cost allocation tag."
  type        = string
  default     = "assessment"
}
variable "vnet_address_space" {
  description = "Non-overlapping IPv4 VNet range; two /24 subnets are derived from it."
  type        = string
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrsubnet(var.vnet_address_space, 8, 2)) && can(regex("/16$", var.vnet_address_space)) && can(cidrnetmask(var.vnet_address_space))
    error_message = "Supply an IPv4 /16 range that does not overlap your enterprise network."
  }
}
variable "readers_group_object_id" {
  description = "Existing COMPANYA_READERS group object ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.readers_group_object_id))
    error_message = "Supply a group object ID in UUID format."
  }
}
variable "writers_group_object_id" {
  description = "Existing COMPANYA_WRITERS group object ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.writers_group_object_id)) && var.writers_group_object_id != var.readers_group_object_id
    error_message = "Supply a UUID different from the Readers group ID."
  }
}
variable "pim_start_date_time" {
  description = "Fixed RFC3339 UTC start of the 90-day eligibility period; keep unchanged on redeploy."
  type        = string
  validation {
    condition     = can(formatdate("YYYY-MM-DD", var.pim_start_date_time))
    error_message = "Supply a valid RFC3339 timestamp, such as 2026-11-14T12:00:00Z."
  }
}
