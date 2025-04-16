terraform {
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  }

# features est obligatoire dans les versions récentes du fournisseur azurerm et doit être présent, même si vide. Ce bloc indique à Terraform que le fournisseur Azure est correctement configuré pour être utilisé.
provider "azurerm" {
  features {}
}
 