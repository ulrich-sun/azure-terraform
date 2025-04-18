terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.26.0"
    }
  }
}
provider "azurerm" {
  features {
  }
  resource_provider_registrations = "none"
}


resource "azurerm_resource_group" "rg" {
  name     = "rg-tp2"
  location = "West Europe"
}
