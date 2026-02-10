variable "name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where VNet will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "region"
  type = string
}

variable "endpoint_private_ip" {
  description = "private endpoint ip"
  type = map(string)
}

variable "subnet_id" {
  description = "subnet id"
  type = string
}