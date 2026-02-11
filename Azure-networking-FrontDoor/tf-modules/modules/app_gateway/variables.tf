variable "app_gateway_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the VM in"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where NIC will be attached"
  type        = string
}

# variable "webapp_private_ips" {
#   description = "webapp private ips"
#   type = list(string)
# }

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "webapp01_dns_value" {
  description = "webapp01 dns value"
  type = string
}


variable "webapp02_dns_value" {
  description = "webapp01 dns value"
  type = string
}

variable "environment" {
  description = "define environment prod, dev, uat, preprod"
  type = string
}

variable "appgw_nsg_name" {
  description = "network security group name"
  type = string
}