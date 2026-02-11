resource "azurerm_virtual_network" "vnet" {
	name                = var.name
	location            = var.region
	resource_group_name = var.resource_group_name
	address_space       = var.address_space

	tags = var.tags
}

resource "azurerm_subnet" "subnet" {
	name                 = var.subnet_name
	resource_group_name  = var.resource_group_name
	virtual_network_name = azurerm_virtual_network.vnet.name
	address_prefixes     = [var.subnet_prefix]
	default_outbound_access_enabled = var.default_outbound_access_enabled

	# Delegation for App Service VNet integration
	# Required when using virtual_network_subnet_id for regional VNet integration
	# delegation {
	# 	name = "appservice"
	# 	service_delegation {
	# 		name = "Microsoft.Web/serverFarms"
	# 	}
	# }
}

