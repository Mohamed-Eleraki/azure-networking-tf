
output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.subnet.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.subnet.name
}

output "subnet_prefix" {
  description = "CIDR prefix used for the subnet"
  value       = azurerm_subnet.subnet.address_prefixes[0]
}
