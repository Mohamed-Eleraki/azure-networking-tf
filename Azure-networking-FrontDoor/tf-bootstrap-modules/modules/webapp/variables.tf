variable "name" {
  description = "Name of the App Service (web app)"
  type        = string
}

variable "plan_name" {
  description = "Optional name of the App Service Plan. If null, defaults to <name>-plan"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of the resource group where the app will be created"
  type        = string
}

variable "region" {
  description = "Azure location/region for the resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "service_plan_id" {
  description = "Service Plan ID for the App Service"
  type = string
}

variable "private_endpoint_ip" {
  description = "Private endpoint IP address for the App Service"
  type = string
}
variable "subnet_id" {
  description = "Subnet ID where the App Service will be deployed"
  type = string
}