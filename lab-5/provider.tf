terraform {
  required_version = ">= 1.11.4"
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "my-terraform-rg"
    storage_account_name = "azure-backend-<votre prénom>"
    container_name       = "backend"
    key                  = "terraform.tfstate"
  }
}


provider "azurerm" {
  features {
  }
  
}
