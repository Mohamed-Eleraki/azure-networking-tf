output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.this.name
}

output "subnet_prefix" {
  description = "CIDR prefix used for the subnet"
  value       = azurerm_subnet.this.address_prefixes[0]
}
