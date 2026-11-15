variable "resource_group_id" {
  type        = string
  description = "Resource group access scope."
}

variable "subscription_id" {
  type        = string
  description = "Subscription containing the built-in role definitions."
}

variable "principal_id" {
  type        = string
  description = "Shared application identity principal ID."
}

variable "vault_id" {
  type        = string
  description = "Key Vault scope."
}

variable "container_id" {
  type        = string
  description = "Blob container scope."
}

variable "insights_id" {
  type        = string
  description = "Application Insights scope."
}

variable "readers_group_object_id" {
  type        = string
  description = "Existing Readers group."
}

variable "writers_group_object_id" {
  type        = string
  description = "Existing Writers group."
}

variable "pim_start_date_time" {
  type        = string
  description = "Fixed start of eligibility period."
}
