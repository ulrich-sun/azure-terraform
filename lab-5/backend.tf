terraform {
  backend "azurerm" {
    resource_group_name  = "tfeazytraining-rg"
    storage_account_name = "eazytrainingstorage23"
    container_name       = "eazytraining-container"
    key                  = "lab-5.terraform.tfstate"
  }
}
