############################
# Azure Front Door
############################

###########
# Profile #
###########
resource "azurerm_cdn_frontdoor_profile" "fd-profile" {
  name                = "eraki-fd-profile"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

#############
# EndPoints #
#############
resource "azurerm_cdn_frontdoor_endpoint" "fd-endpoint" {  # Front Door front-end / you can end up having multiple endpoints (prod, dev) at the same profile
  name                     = "eraki-fd-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id
}

############
# Back-end #
############
resource "azurerm_cdn_frontdoor_origin_group" "fd-backend-group" {  # Back-end Group
  name                     = "agw-origins"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd-profile.id

  load_balancing {}

  health_probe {
    protocol            = "Http"
    path                = "/"
    interval_in_seconds = 60
  }
}

resource "azurerm_cdn_frontdoor_origin" "fd-backend-instances" { # Back-end instance
  for_each = var.appgw_FQDN

  name                          = "fd-backend-instances"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd-backend-group.id
  enabled = true
  certificate_name_check_enabled = false
  # host_name                     = azurerm_public_ip.east.fqdn
  # host_name = "agw-east.example.com"  # DNS name
  host_name 					= each.value
  http_port                     = 80
  priority                      = 1
  weight                        = 100

  # Ignore changes to prevent recreation conflicts
  # lifecycle {
  #   ignore_changes = [
  #     enabled,
  #     host_name,
  #     http_port,
  #     https_port,
  #     priority,
  #     weight
  #   ]
  # }
}


#########
# Route #
#########
resource "azurerm_cdn_frontdoor_route" "fd-route" {
  name                          = "default"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd-endpoint.id  # link with specific endpoint
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd-backend-group.id  # Backend group

  cdn_frontdoor_origin_ids = [
    for origin in azurerm_cdn_frontdoor_origin.fd-backend-instances : origin.id 
  ]

  patterns_to_match   = ["/*"]
  supported_protocols = ["Http"]
#   forwarding_protocol = "HttpOnly"
  https_redirect_enabled = false
  forwarding_protocol       = "MatchRequest"
}



# resource "azurerm_frontdoor_firewall_policy" "fd-waf" {
#   name                = "erakifdwaf"
#   resource_group_name = var.resource_group_name

#   managed_rule {
#     type    = "DefaultRuleSet"  # OWASP
#     version = "3.2"

#     # optional
#     # rule_group_override {
#     #   rule_group_name = "RequestBody"
#     #   rules {
#     #     rule_id = "981245"
#     #     action  = "Log"
#     #   }
#     # }
#   }
# }
