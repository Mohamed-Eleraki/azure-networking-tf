variable "resource_group_name" {
  description = "resoruce group name of front door"
  type = string
}

variable "appgw_FQDN" {
  description = "list of app gateway appgw_FQDN"
  type = map(string)
}