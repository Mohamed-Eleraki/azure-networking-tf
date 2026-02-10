variable "record_name" {
  description = "record name of dns private zone"
  type = string
}
variable "zone_name" {
  description = "zone name will hold these records"
  type = string
}
variable "private_ip" {
  description = "private ip for a record"
  type = list(string)
}

variable "resource_group_name" {}