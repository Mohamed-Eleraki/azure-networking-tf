terraform {
  cloud {

    organization = "HCP-remote-organization"

    workspaces {
      name = "Demo01"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}