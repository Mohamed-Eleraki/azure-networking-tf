output "app_service_id" {
  description = "ID of the created App Service"
  value       = azurerm_app_service.app_service.id
}

output "app_service_name" {
  description = "Name of the created App Service"
  value       = azurerm_app_service.app_service.name
}

output "default_site_hostname" {
  description = "Hostname of the created App Service"
  value       = azurerm_app_service.app_service.default_site_hostname
}
output "webapp_id" {
  description = "The ID of the Web App"
  value       = azurerm_app_service.app_service.id
}