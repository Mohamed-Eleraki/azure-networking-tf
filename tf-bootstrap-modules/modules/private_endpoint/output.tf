# list all output
output "private_endpoint_id" {
  description = "ID of the created private endpoint"
  value       = azurerm_private_endpoint.pe.id
}