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
# resource_provider_registrations = "none"
  subscription_id = {subscription_id}
}
