
##################
# Resource Group #
##################
module "rg_hub" {
  source              = "../../tf-modules/modules/rg"
  resource_group_name = "eraki-hub-shr-rg"
  region              = var.region_us
  tags                = local.all_tags
}

module "rg_spoke" {
  source              = "../../tf-modules/modules/rg"
  resource_group_name = "eraki-spk-rg"
  region              = var.region_us
  tags                = local.all_tags
}

###################
# Virtual Network #
###################
module "vnet_hub_us" {
  source                          = "../../tf-modules/modules/vnet"
  name                            = "eraki-hub-us-vnet"
  region                          = var.region_us
  resource_group_name             = module.rg_hub.resource_group_name
  address_space                   = ["10.1.0.0/16"]
  subnet_name                     = "eraki-hub-us-subnet"
  subnet_prefix                   = "10.1.1.0/24"
  default_outbound_access_enabled = true
  tags                            = local.all_tags
}
module "vnet_hub_eu" {
  source                          = "../../tf-modules/modules/vnet"
  name                            = "eraki-hub-eu-vnet"
  region                          = var.region_eu
  resource_group_name             = module.rg_hub.resource_group_name
  address_space                   = ["10.1.0.0/16"]
  subnet_name                     = "eraki-hub-eu-subnet"
  subnet_prefix                   = "10.1.1.0/24"
  default_outbound_access_enabled = true
  tags                            = local.all_tags
}

module "vnet_spoke_us" {
  source                          = "../../tf-modules/modules/vnet"
  name                            = "eraki-spk-us-vnet"
  region                          = var.region_us
  resource_group_name             = module.rg_spoke.resource_group_name
  address_space                   = ["10.2.0.0/16"]
  subnet_name                     = "eraki-spk-us-subnet"
  subnet_prefix                   = "10.2.1.0/24"
  default_outbound_access_enabled = false
  tags                            = local.all_tags
}
module "vnet_spoke_eu" {
  source                          = "../../tf-modules/modules/vnet"
  name                            = "eraki-spk-eu-vnet"
  region                          = var.region_eu
  resource_group_name             = module.rg_spoke.resource_group_name
  address_space                   = ["10.2.0.0/16"]
  subnet_name                     = "eraki-spk-eu-subnet"
  subnet_prefix                   = "10.2.1.0/24"
  default_outbound_access_enabled = false
  tags                            = local.all_tags
}

# peering us
module "vnet_peering_hub-us_to_spoke-us" {
  source = "../../tf-modules/modules/vnet-peering"
  peering_name = "eraki-hub_us-to-spk_us-peering"
  resource_group_name = module.rg_hub.resource_group_name
  virtual_network_name = module.vnet_hub_us.vnet_name
  remote_virtual_network_id = module.vnet_spoke_us.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = false
  allow_gateway_transit = false
  use_remote_gateways = false
}
module "vnet_peering_spoke-us_to_hub-us" {
  source = "../../tf-modules/modules/vnet-peering"
  peering_name = "eraki-spk_us-to-hub_us-peering"
  resource_group_name = module.rg_spoke.resource_group_name
  virtual_network_name = module.vnet_spoke_us.vnet_name
  remote_virtual_network_id = module.vnet_hub_us.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = false
  allow_gateway_transit = false
  use_remote_gateways = false
}

# peering eu
module "vnet_peering_hub-eu_to_spoke-eu" {
  source = "../../tf-modules/modules/vnet-peering"
  peering_name = "eraki-hub_eu-to-spk_eu-peering"
  resource_group_name = module.rg_hub.resource_group_name
  virtual_network_name = module.vnet_hub_eu.vnet_name
  remote_virtual_network_id = module.vnet_spoke_eu.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = false
  allow_gateway_transit = false
  use_remote_gateways = false
}
module "vnet_peering_spoke-eu_to_hub-eu" {
  source = "../../tf-modules/modules/vnet-peering"
  peering_name = "eraki-spk_eu-to-hub_eu-peering"
  resource_group_name = module.rg_spoke.resource_group_name
  virtual_network_name = module.vnet_spoke_eu.vnet_name
  remote_virtual_network_id = module.vnet_hub_eu.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = false
  allow_gateway_transit = false
  use_remote_gateways = false
}

####################
# App Gateway - US #
####################
module "app_gateway_subnet_us" {
  source = "../../tf-modules/modules/subnets"
  subnet_name = "eraki-hub-us-agsubnet"
  resource_group_name = module.rg_hub.resource_group_name
  vnet_name = module.vnet_hub_us.vnet_name
  subnet_prefix = "10.1.10.0/24"
}

module "app_gateway_us" {
  source              = "../../tf-modules/modules/app_gateway"
  app_gateway_name = "eraki-hub-us-appgw"
  region = var.region_us
  resource_group_name = module.rg_hub.resource_group_name
  tags = local.all_tags
  subnet_id = module.app_gateway_subnet_us.subnet_id
  environment = "Prod"

  webapp01_dns_value = "webapp01.netspoke.hub.internal"
  webapp02_dns_value = "webapp02.netspoke.hub.internal"
  
  appgw_nsg_name = "appgw-nsg-us"
}

####################
# App Gateway - EU #
####################
module "app_gateway_subnet_eu" {
  source = "../../tf-modules/modules/subnets"
  subnet_name = "eraki-hub-eu-subnet02"
  resource_group_name = module.rg_hub.resource_group_name
  vnet_name = module.vnet_hub_eu.vnet_name
  subnet_prefix = "10.1.3.0/24"
}

module "app_gateway_eu" {
  source              = "../../tf-modules/modules/app_gateway"
  app_gateway_name = "eraki-hub-eu-appgw"
  region = var.region_eu
  resource_group_name = module.rg_hub.resource_group_name
  tags = local.all_tags
  subnet_id = module.app_gateway_subnet_eu.subnet_id
  environment = "Dev"

  webapp01_dns_value = "webapp03.netspoke.hub.internal"
  webapp02_dns_value = "webapp04.netspoke.hub.internal"

  appgw_nsg_name = "appgw-nsg-eu"
}

#############################
# Private DNS Zone, Records #
#############################
module "private_dns_zone_hub" {
  depends_on = [
    module.vnet_peering_hub-us_to_spoke-us,
    module.vnet_peering_spoke-us_to_hub-us,
    module.vnet_peering_hub-eu_to_spoke-eu,
    module.vnet_peering_spoke-eu_to_hub-eu
  ]

  source                = "../../tf-modules/modules/private_dns_zone"
  private_dns_zone_name = "netspoke.hub.internal"
  resource_group_name   = module.rg_hub.resource_group_name

  virtual_network_ids    = {
    spoke_us = module.vnet_spoke_us.vnet_id
    spoke_eu = module.vnet_spoke_eu.vnet_id
    hub_us   = module.vnet_hub_us.vnet_id
    hub_eu   = module.vnet_hub_eu.vnet_id
  }

  tags                  = local.all_tags
}
module "private_dns_records_webapp01" {
  source                = "../../tf-modules/modules/private_dns_records"
  record_name = "webapp01"
  zone_name = module.private_dns_zone_hub.private_dns_zone_name
  resource_group_name   = module.rg_hub.resource_group_name
  private_ip = [module.private_endpoint_webapp01.private_ip]
}
module "private_dns_records_webapp02" {
  source                = "../../tf-modules/modules/private_dns_records"
  record_name = "webapp02"
  zone_name = module.private_dns_zone_hub.private_dns_zone_name
  resource_group_name   = module.rg_hub.resource_group_name
  private_ip = [module.private_endpoint_webapp02.private_ip]
}
module "private_dns_records_webapp03" {
  source                = "../../tf-modules/modules/private_dns_records"
  record_name = "webapp03"
  zone_name = module.private_dns_zone_hub.private_dns_zone_name
  resource_group_name   = module.rg_hub.resource_group_name
  private_ip = [module.private_endpoint_webapp03.private_ip]
}
module "private_dns_records_webapp04" {
  source                = "../../tf-modules/modules/private_dns_records"
  record_name = "webapp04"
  zone_name = module.private_dns_zone_hub.private_dns_zone_name
  resource_group_name   = module.rg_hub.resource_group_name
  private_ip = [module.private_endpoint_webapp04.private_ip]
}

######################
# Web Application US #
######################
module "service_plan_spk_us" {
  source              = "../../tf-modules/modules/service-plan"
  name           = "eraki-spk-us-sp"
  region              = var.region_us
  resource_group_name = module.rg_spoke.resource_group_name
  os_type             = "Linux"
  sku_size            = "S1"
  tags                = local.all_tags
}

module "webapp_spoke01" {
  depends_on = [ module.service_plan_spk_us ]

  source              = "../../tf-modules/modules/webapp"
  name                = "eraki-spk-us-wa-01"
  region              = var.region_us
  resource_group_name = module.rg_spoke.resource_group_name
  service_plan_id = module.service_plan_spk_us.service_plan_id
  private_endpoint_ip = module.private_endpoint_webapp01.private_ip
  subnet_id           = module.vnet_spoke_us.subnet_id
  tags                = local.all_tags
}

module "webapp_spoke02" {
  depends_on = [ module.service_plan_spk_us ]

  source              = "../../tf-modules/modules/webapp"
  name                = "eraki-spk-us-wa-02"
  region              = var.region_us
  resource_group_name = module.rg_spoke.resource_group_name
  service_plan_id = module.service_plan_spk_us.service_plan_id
  private_endpoint_ip = module.private_endpoint_webapp02.private_ip
  subnet_id           = module.vnet_spoke_us.subnet_id
  tags                = local.all_tags
}

######################
# Web Application EU #
######################
module "service_plan_spk_eu" {
  source              = "../../tf-modules/modules/service-plan"
  name           = "eraki-spk-eu-sp"
  region              = var.region_eu
  resource_group_name = module.rg_spoke.resource_group_name
  os_type             = "Linux"
  sku_size            = "P1v2"
  tags                = local.all_tags
}

module "webapp_spoke03" {
  depends_on = [ module.service_plan_spk_eu ]
  source              = "../../tf-modules/modules/webapp"
  name                = "eraki-spk-eu-wa-03"
  region              = var.region_eu
  resource_group_name = module.rg_spoke.resource_group_name
  service_plan_id = module.service_plan_spk_eu.service_plan_id
  private_endpoint_ip = module.private_endpoint_webapp03.private_ip
  subnet_id           = module.vnet_spoke_eu.subnet_id
  tags                = local.all_tags
}

module "webapp_spoke04" {
  depends_on = [ module.service_plan_spk_eu ]

  source              = "../../tf-modules/modules/webapp"
  name                = "eraki-spk-eu-wa-04"
  region              = var.region_eu
  resource_group_name = module.rg_spoke.resource_group_name
  service_plan_id = module.service_plan_spk_eu.service_plan_id
  private_endpoint_ip = module.private_endpoint_webapp04.private_ip
  subnet_id           = module.vnet_spoke_eu.subnet_id
  tags                = local.all_tags
}

#######################
# Private Endpoint US #
#######################
module "pe_subnet_us" {
  source = "../../tf-modules/modules/subnets"
  subnet_name = "eraki-spk-us-pe_subnet"
  resource_group_name = module.rg_spoke.resource_group_name
  vnet_name = module.vnet_spoke_us.vnet_name
  subnet_prefix = "10.2.2.0/24"
}

module "private_endpoint_webapp01" {
  source                         = "../../tf-modules/modules/private_endpoint"
  private_endpoint_name          = "eraki-spk-us-pe-01"
  region                         = var.region_us
  subnet_id                      = module.pe_subnet_us.subnet_id
  resource_group_name            = module.rg_spoke.resource_group_name
  private_connection_resource_id = module.webapp_spoke01.webapp_id
  subresource_names              = ["sites"]
  tags                           = local.all_tags
}

module "private_endpoint_webapp02" {
  source                         = "../../tf-modules/modules/private_endpoint"
  private_endpoint_name          = "eraki-spk-us-pe-02"
  region                         = var.region_us
  subnet_id                      = module.pe_subnet_us.subnet_id
  resource_group_name            = module.rg_spoke.resource_group_name
  private_connection_resource_id = module.webapp_spoke02.webapp_id
  subresource_names              = ["sites"]
  tags                           = local.all_tags
}

module "pe_nsg_us" {
  source                         = "../../tf-modules/modules/webapp-pe-nsg"
  name = "eraki-spk-us-nsg"
  region = var.region_us
  resource_group_name            = module.rg_spoke.resource_group_name
  tags                           = local.all_tags
  subnet_id = module.pe_subnet_us.subnet_id
  endpoint_private_ip = {
    webapp_pe01 = module.private_endpoint_webapp01.private_ip,
    webapp_pe02 = module.private_endpoint_webapp02.private_ip
  }
}

#######################
# Private Endpoint EU #
#######################
module "pe_subnet_eu" {
  source = "../../tf-modules/modules/subnets"
  subnet_name = "eraki-spk-eu-pe_subnet"
  resource_group_name = module.rg_spoke.resource_group_name
  vnet_name = module.vnet_spoke_eu.vnet_name
  subnet_prefix = "10.2.2.0/24"
}

module "private_endpoint_webapp03" {
  source                         = "../../tf-modules/modules/private_endpoint"
  private_endpoint_name          = "eraki-spk-eu-pe-03"
  region                         = var.region_eu
  subnet_id                      = module.pe_subnet_eu.subnet_id
  resource_group_name            = module.rg_spoke.resource_group_name
  private_connection_resource_id = module.webapp_spoke03.webapp_id
  subresource_names              = ["sites"]
  tags                           = local.all_tags
}

module "private_endpoint_webapp04" {
  source                         = "../../tf-modules/modules/private_endpoint"
  private_endpoint_name          = "eraki-spk-eu-pe-04"
  region                         = var.region_eu
  subnet_id                      = module.pe_subnet_eu.subnet_id
  resource_group_name            = module.rg_spoke.resource_group_name
  private_connection_resource_id = module.webapp_spoke04.webapp_id
  subresource_names              = ["sites"]
  tags                           = local.all_tags
}

module "pe_nsg_eu" {
  source                         = "../../tf-modules/modules/webapp-pe-nsg"
  name = "eraki-spk-eu-nsg"
  region = var.region_eu
  resource_group_name            = module.rg_spoke.resource_group_name
  tags                           = local.all_tags
  subnet_id = module.pe_subnet_eu.subnet_id
  endpoint_private_ip = {
    webapp_pe03 = module.private_endpoint_webapp03.private_ip,
    webapp_pe04 = module.private_endpoint_webapp04.private_ip
  }
}

##############
# Front Door #
##############
module "frontdoor" {
  source = "../../tf-modules/modules/front-door"
  resource_group_name = module.rg_hub.resource_group_name
  appgw_FQDN = {
    appgw01 = "eraki-hub-us-appgw.eastus.cloudapp.azure.com",
    appgw02 = "eraki-hub-eu-appgw.westeurope.cloudapp.azure.com"
    }
}