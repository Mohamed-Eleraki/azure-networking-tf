resource "azurerm_public_ip" "appgateway_pip" {
	name                = "${var.app_gateway_name}-pip"
	location            = var.region
	resource_group_name = var.resource_group_name
	allocation_method   = "Static"
	sku = "Standard"
	tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name = var.app_gateway_name
  location = var.region
  resource_group_name = var.resource_group_name
  firewall_policy_id = azurerm_web_application_firewall_policy.appgw_waf_policy.id
  sku {
	name = "WAF_v2"
	tier = "WAF_v2"
	capacity = 2
  }

  gateway_ip_configuration {
	name = "appgw-ipcfg"
	subnet_id = var.subnet_id
  }
  frontend_ip_configuration {
	name = "appgw-frontend"
	public_ip_address_id = azurerm_public_ip.appgateway_pip.id
	# private_ip_address = "10.1.1.10"
	# private_ip_address_allocation = "Static"
	# subnet_id = var.subnet_id
  }
  frontend_port {
	name = "http-port"
	port = 80
  }
#   backend_address_pool {
# 	name = "webapp-backend"
# 	ip_addresses = var.webapp_private_ips
#   }
  backend_address_pool {
	name = "webapp-backend"
	fqdns = [
		var.webapp01_dns_value,
		var.webapp02_dns_value,
	]
  }
  backend_http_settings {
	name = "http-settings"
	port = 80
	protocol = "Http"
	cookie_based_affinity = "Disabled"
	# path = "/path1/"
	request_timeout = 60
  }
  http_listener {
	name = "http-listener"
	frontend_ip_configuration_name = "appgw-frontend"
	frontend_port_name = "http-port"
	protocol = "Http"
  }
  request_routing_rule {
	name = "routing-rule"
	priority = 9
	rule_type = "Basic"
	http_listener_name = "http-listener"
	backend_address_pool_name = "webapp-backend"
	backend_http_settings_name = "http-settings"
  }
  probe {  # force apply this avoiding 502 error
	host = "webapp01.netspoke.hub.internal"
	interval = 30
	name = "webapp01.netspoke.hub.internal"
	path = "/"
	pick_host_name_from_backend_http_settings = false
	port = 80
	protocol = "Http"
	timeout = 30
	unhealthy_threshold = 3
	match {
	  status_code = ["400-410"]
	}
  }
  tags = var.tags
}

# WAF Policy 
resource "azurerm_web_application_firewall_policy" "appgw_waf_policy" {
  name = "${var.app_gateway_name}-waf-policy"
  resource_group_name = var.resource_group_name
  location = var.region
  policy_settings {
	enabled = true
	mode = var.environment == "prod" ? "Prevention" : "Detection"
	request_body_check = true
	file_upload_limit_in_mb = 100
	max_request_body_size_in_kb = 256
  }
  managed_rules {
	managed_rule_set {
	  type = "OWASP"
	  version = "3.2"
	  rule_group_override {
		rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
		rule {
			# 920300: noisy for App Gateway probes & some clients → log only
			# 920300: Missing/malformed Host header → high noise (probes, legacy clients), log only
			id = "920300"
			enabled = true
			action = "Log"
		}
		rule {
		  # 920440: real attack vector → block
		  # 920440: URL encoding evasion (double-encoding, obfuscation) → real attack, block
		  id = "920440"
		  enabled = true
		  action = "Block"
		}
	  }
	}
  }
  tags = var.tags
}

resource "azurerm_network_security_group" "appgw_nsg" {
  name                = var.appgw_nsg_name
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_frontdoor_to_appgw_https" {
  name                        = "Allow-FrontDoor-HTTPS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureFrontDoor.Backend"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw_nsg.name
}
resource "azurerm_network_security_rule" "allow_gateway_manager" {
  name                        = "Allow-GatewayManager"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"

  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw_nsg.name
}

# resource "azurerm_network_security_rule" "deny_all_inbound" {
#   name                        = "Deny-All-Inbound"
#   priority                    = 2001
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.appgw_nsg.name
# }
resource "azurerm_subnet_network_security_group_association" "appgw_nsg_assoc" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}
