
resource "azurerm_private_dns_a_record" "webapp_record" {
  name                = var.record_name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = var.private_ip
}
