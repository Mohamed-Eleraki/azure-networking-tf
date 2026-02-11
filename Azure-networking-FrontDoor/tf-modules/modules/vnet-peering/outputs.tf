output "vnet_peering_id" {
  description = "The ID of the VNet peering"
  value       = azurerm_virtual_network_peering.vnet-peering.id
}
output "vnet_peering_name" {
  description = "The name of the VNet peering"
  value       = azurerm_virtual_network_peering.vnet-peering.name
}