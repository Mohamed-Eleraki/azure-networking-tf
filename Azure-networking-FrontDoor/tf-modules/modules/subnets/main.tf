
resource "azurerm_subnet" "subnet" {
	name                 = var.subnet_name
	resource_group_name  = var.resource_group_name
	virtual_network_name = var.vnet_name
	address_prefixes     = [var.subnet_prefix]
	default_outbound_access_enabled = var.default_outbound_access_enabled

	# optional delegation, network policies, service endpoints can be added later
}
