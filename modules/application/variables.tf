variable "resource_group_name" {
  type        = string
  description = "Resource group containing the platform."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "name_prefix" {
  type        = string
  description = "Environment and workload naming prefix."
}

variable "tags" {
  type        = map(string)
  description = "Standard resource tags."
}

variable "suffix" {
  type        = string
  description = "Stable suffix for globally unique names."
}

variable "integration_subnet_id" {
  type        = string
  description = "Delegated outbound integration subnet."
}

variable "endpoint_subnet_id" {
  type        = string
  description = "Private endpoint subnet."
}

variable "dns_zone_ids" {
  type        = map(string)
  description = "Vault, Blob and Web App private DNS zone IDs."
}

variable "workspace_id" {
  type        = string
  description = "Diagnostic log destination."
}

variable "insights_connection_string" {
  type        = string
  description = "Telemetry endpoint information; ingestion still requires Entra authentication."
  sensitive   = true
}
