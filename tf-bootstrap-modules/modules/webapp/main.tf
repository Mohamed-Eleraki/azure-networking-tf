resource "azurerm_app_service_plan" "this" {
	name                = coalesce(var.plan_name, "${var.name}-plan")
	location            = var.location
	resource_group_name = var.resource_group_name

	sku {
		tier = var.sku_tier
		size = var.sku_size
	}

	tags = var.tags
}

resource "azurerm_app_service" "this" {
	name                = var.name
	location            = var.location
	resource_group_name = var.resource_group_name
	app_service_plan_id = azurerm_app_service_plan.this.id

	site_config {
		always_on = true
	}

	tags = var.tags
}

