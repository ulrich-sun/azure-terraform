resource "azurerm_storage_account" "eazytraining-sa" {
  #name                     = "storage-account-azure-votreprenom-eazytraining"
  name                     = var.storage_account_name #"eazytrainingstorage23"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "eazytraining-container" {
  name                  = "eazytraining-container"
  storage_account_name  = var.storage_account_name  # ✅ correct
  container_access_type = "private"
}