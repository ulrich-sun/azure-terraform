terraform {
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "my-terraform-rg"
    storage_account_name = "myeazytrainingstorage"
    container_name       = "backend"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
}