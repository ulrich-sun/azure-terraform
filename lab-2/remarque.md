du à l'erreur suivante :

 Error: static IP allocation must be used when creating Standard SKU public IP addresses
│ 
│   with azurerm_public_ip.tfeazytraining-ip,
│   on main.tf line 28, in resource "azurerm_public_ip" "tfeazytraining-ip":
│   28: resource "azurerm_public_ip" "tfeazytraining-ip" {


j'ai remplacer ca 


resource "azurerm_public_ip" "tfeazytraining-ip" {
  name                = "my-eazytraining-public-ip"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "my-eazytraining-env"
  }
}


par ca: 

resource "azurerm_public_ip" "tfeazytraining-ip" {
  name                = "my-eazytraining-public-ip"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "my-eazytraining-env"
  }
}