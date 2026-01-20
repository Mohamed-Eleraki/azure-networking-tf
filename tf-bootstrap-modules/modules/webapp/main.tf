resource "azurerm_service_plan" "service_plan" {
	name                = coalesce(var.plan_name, "${var.name}-plan")
	location            = var.region
	resource_group_name = var.resource_group_name

	os_type = var.os_type

	sku_name = var.sku_size

	tags = var.tags
}

resource "azurerm_app_service" "app_service" {
	name                = var.name
	location            = var.region
	resource_group_name = var.resource_group_name
	app_service_plan_id = azurerm_service_plan.service_plan.id

	site_config {
		always_on = true
	}

	tags = var.tags
}

