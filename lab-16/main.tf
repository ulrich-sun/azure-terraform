provider "azurerm" {
  features {}
  
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tp2"
  location = "West Europe"
}
