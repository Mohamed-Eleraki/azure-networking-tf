variable "private_dns_zone_name" {
  description = "Name of the Private DNS Zone"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where Private DNS Zone will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Private DNS Zone"
  type        = map(string)
  default     = {}
}