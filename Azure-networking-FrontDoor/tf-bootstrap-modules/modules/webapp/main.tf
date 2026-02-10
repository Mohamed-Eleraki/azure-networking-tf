
resource "azurerm_linux_web_app" "app_service" {
	name                = var.name
	location            = var.region
	resource_group_name = var.resource_group_name
	service_plan_id     = var.service_plan_id
	public_network_access_enabled = false

	# System Assigned Managed Identity allows Terraform to manage the resource
	# without needing to fetch publishing credentials over the network
	# identity {
	# 	type = "SystemAssigned"
	# }

	site_config {
		always_on = true
	}

	tags = var.tags
}
