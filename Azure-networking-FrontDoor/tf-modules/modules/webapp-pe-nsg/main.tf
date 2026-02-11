

resource "azurerm_network_security_group" "webapp_nsg" {
	name                = var.name
	location            = var.region
	resource_group_name = var.resource_group_name
	tags = var.tags
}
resource "azurerm_network_security_rule" "allow_80_for_endpoint" {
  for_each = var.endpoint_private_ip
  name                        = "Allow-80-From-enpoint-${each.key}"
  priority                    = 100 + index(keys(var.endpoint_private_ip), each.key)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.webapp_nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "webapp_pe_nsg_assoc" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.webapp_nsg.id
}
