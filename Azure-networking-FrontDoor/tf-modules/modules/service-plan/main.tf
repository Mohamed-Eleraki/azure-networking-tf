resource "azurerm_service_plan" "service_plan" {
	name                = var.name
	location            = var.region
	resource_group_name = var.resource_group_name

	os_type = var.os_type

	sku_name = var.sku_size

	tags = var.tags
}
