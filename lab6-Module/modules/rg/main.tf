resource "azurerm_resource_group" "eazy-rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = var.environment
  }
}
