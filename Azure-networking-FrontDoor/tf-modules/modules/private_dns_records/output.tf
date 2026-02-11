output "fqdn_record" {
  value = azurerm_private_dns_a_record.webapp_record.fqdn
}