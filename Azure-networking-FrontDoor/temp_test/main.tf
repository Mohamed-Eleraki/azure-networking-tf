terraform {
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatest01"
  #   container_name       = "tfstatecontainer"
  #   key                  = "dev04.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = "856880af-e2ac-41b2-b5fb-e7ebfe4d97bc"
}

############################
# Resource Group
############################
resource "azurerm_resource_group" "rg" {
  name     = "rg-fd-agw-demo"
  location = "East US"
}

############################
# Networking
############################
resource "azurerm_virtual_network" "east" {
  name                = "vnet-eastus"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "east_agw" {
  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.east.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_virtual_network" "we" {
  name                = "vnet-westeurope"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "we_agw" {
  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.we.name
  address_prefixes     = ["10.20.1.0/24"]
}

############################
# Public IPs
############################
resource "azurerm_public_ip" "east" {
  name                = "pip-agw-eastus"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "we" {
  name                = "pip-agw-westeurope"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

############################
# Application Gateways
############################
resource "azurerm_application_gateway" "east" {
  name                = "agw-eastus"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "ipcfg"
    subnet_id = azurerm_subnet.east_agw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.east.id
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "http"
    protocol                       = "Http"
    host_name = "agw-east.example.com"
  }

  backend_address_pool {
    name = "backend"
  }

  backend_http_settings {
    name                  = "http"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
  }

  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "backend"
    backend_http_settings_name = "http"
    priority                   = 10
  }
}

resource "azurerm_application_gateway" "we" {
  name                = "agw-westeurope"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "ipcfg"
    subnet_id = azurerm_subnet.we_agw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.we.id
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "http"
    protocol                       = "Http"
    host_name = "agw-we.example.com"
  }

  backend_address_pool {
    name = "backend"
  }

  backend_http_settings {
    name                  = "http"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
  }

  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "backend"
    backend_http_settings_name = "http"
    priority                   = 10
  }
}

############################
# Azure Front Door
############################

###########
# Profile #
###########
resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = "fd-demo"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

#############
# EndPoints #
#############
resource "azurerm_cdn_frontdoor_endpoint" "fd" {  # Front Door front-end / you can end up having multiple endpoints (prod, dev) at the same profile
  name                     = "fd-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

############
# Back-end #
############
resource "azurerm_cdn_frontdoor_origin_group" "agw" {  # Back-end Group
  name                     = "agw-origins"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  load_balancing {}

  health_probe {
    protocol            = "Http"
    path                = "/"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "east" { # Back-end instance
  name                          = "agw-eastus"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.agw.id
  # host_name                     = azurerm_public_ip.east.fqdn
  host_name = "agw-east.example.com"  # DNS name
  http_port                     = 80
  priority                      = 1
  weight                        = 50
  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_origin" "we" {  # Back-end instance
  name                          = "agw-westeurope"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.agw.id
  # host_name                     = azurerm_public_ip.we.fqdn
  host_name = "agw-we.example.com"
  http_port                     = 80
  priority                      = 1
  weight                        = 50
  certificate_name_check_enabled = false
}

#########
# Route #
#########
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd.id  # link with specific endpoint
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.agw.id  # Backend group

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.east.id,
    azurerm_cdn_frontdoor_origin.we.id
  ]

  patterns_to_match   = ["/*"]
  supported_protocols = ["Http"]
  forwarding_protocol = "HttpOnly"
  https_redirect_enabled = false
  # forwarding_protocol       = "MatchRequest"
  # https_redirect_enabled    = true
}

