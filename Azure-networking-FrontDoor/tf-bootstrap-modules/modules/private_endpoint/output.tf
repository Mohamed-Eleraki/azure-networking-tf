# list all output
output "private_endpoint_id" {
  description = "ID of the created private endpoint"
  value       = azurerm_private_endpoint.pe.id
}

output "private_ip" {
  description = "private ip of endpoint"
  value = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address 
}