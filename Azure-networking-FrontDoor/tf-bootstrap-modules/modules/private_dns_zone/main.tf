# private dns zone
resource "azurerm_private_dns_zone" "pdz" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name

  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = var.virtual_network_ids

  name                  = "${var.private_dns_zone_name}-${each.key}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pdz.name
  virtual_network_id    = each.value
  registration_enabled  = false
}