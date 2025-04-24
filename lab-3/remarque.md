du à l'erreur suivante: 

│ Error: creating Network Security Group (Subscription: "9601d4a5-7aed-4827-b717-66c25e897a28"
│ Resource Group Name: "my-eazytraining-rg"
│ Network Security Group Name: "my-eazytraining-nsg"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: InvalidRequestFormat: Cannot parse the request.
│ 
│   with azurerm_network_security_group.tfeazytraining-nsg,
│   on main.tf line 39, in resource "azurerm_network_security_group" "tfeazytraining-nsg":
│   39: resource "azurerm_network_security_group" "tfeazytraining-nsg" {
│ 


j'ai remplacé le bloc suivant : 


resource "azurerm_network_security_group" "tfeazytraining-nsg" {
  name                = "my-eazytraining-nsg"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.web_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "my-eazytraining-env"
  }
}


par 


resource "azurerm_network_security_group" "tfeazytraining-nsg" {
  name                = "my-eazytraining-nsg"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.web_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "my-eazytraining-env"
  }
}