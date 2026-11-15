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

variable "address_space" {
  type        = string
  description = "IPv4 /16 range used to derive two /24 subnets."
}
