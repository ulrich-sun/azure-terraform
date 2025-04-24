du à l'erreru suivante: 

╷
│ Error: Unsupported argument
│ 
│   on provider.tf line 19, in provider "azurerm":
│   19:   resource_provider_registrations = "none"
│ 
│ An argument named "resource_provider_registrations" is not expected here.

j'ai supprimé l'argument resource_provider_registrations du bloc provider


du à l'erreur suivante: 

│ Error: Missing required argument
│ 
│   on ../modules/storage/main.tf line 11, in resource "azurerm_storage_container" "eazytraining-container":
│   11: resource "azurerm_storage_container" "eazytraining-container" {
│ 
│ The argument "storage_account_name" is required, but no definition was found.
╵
╷
│ Error: Unsupported argument
│ 
│   on ../modules/storage/main.tf line 13, in resource "azurerm_storage_container" "eazytraining-container":
│   13:   storage_account_id  = azurerm_storage_account.eazytraining-sa.id
│ 
│ An argument named "storage_account_id" is not expected here.

j'ai remplacé l'argument storage_account_id par storage_account_name