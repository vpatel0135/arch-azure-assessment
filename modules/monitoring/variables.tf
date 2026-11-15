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

variable "endpoint_subnet_id" {
  type        = string
  description = "Private endpoint subnet ID."
}

variable "dns_zone_ids" {
  type        = list(string)
  description = "The five Azure Monitor DNS zones, including the shared Blob zone."
}
