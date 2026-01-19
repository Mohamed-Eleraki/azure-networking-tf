output "app_service_id" {
  description = "ID of the created App Service"
  value       = azurerm_app_service.this.id
}

output "app_service_name" {
  description = "Name of the created App Service"
  value       = azurerm_app_service.this.name
}

output "default_site_hostname" {
  description = "Hostname of the created App Service"
  value       = azurerm_app_service.this.default_site_hostname
}
