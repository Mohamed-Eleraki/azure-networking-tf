variable "subnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where VNet will be created"
  type        = string
}

variable "subnet_prefix" {
  description = "CIDR prefix for the subnet (e.g. 10.0.1.0/24)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}

variable "default_outbound_access_enabled" {
  description = "Enable default outbound access for the subnet"
  type        = bool
  default     = true
  validation {
    condition     = var.default_outbound_access_enabled == true || var.default_outbound_access_enabled == false
    error_message = "default_outbound_access_enabled must be a boolean value"
  }
}

variable "vnet_name" {
  description = "Virtual network name will place in"
  type = string
}

