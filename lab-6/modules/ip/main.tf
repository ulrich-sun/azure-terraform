resource "azurerm_public_ip" "tfeazytraining-ip" {
  name                = "my-eazytraining-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = {
    environment = "my-eazytraining-env"
  }
}
