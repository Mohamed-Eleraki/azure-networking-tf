variable "peering_name" {
  description = "Name of the VNet peering"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group where the VNet exists"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the local VNet"
  type        = string
}

variable "remote_virtual_network_id" {
  description = "The ID of the remote VNet to peer with"
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Allow access to the remote VNet"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic from remote VNet"
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Use remote VNet gateway"
  type        = bool
  default     = false
}