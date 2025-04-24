resource "azurerm_public_ip" "eazy-ip" {
  name                = "my-eazy-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku = "Basic"

 tags = {
    environment = var.environment
  }
}
