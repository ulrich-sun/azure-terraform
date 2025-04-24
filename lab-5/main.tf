resource "azurerm_virtual_network" "tfeazytraining-vnet" {
  name                = "my-eazytraining-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazytraining-env"
  }
}

resource "azurerm_subnet" "tfeazytraining-subnet" {
  name                 = "my-eazytraining-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.tfeazytraining-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "tfeazytraining-ip" {
  name                = "my-eazytraining-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = {
    environment = "my-eazytraining-env"
  }
}

resource "azurerm_network_security_group" "tfeazytraining-nsg" {
  name                = "my-eazytraining-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

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
    priority                   = 1002
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

resource "azurerm_network_interface" "tfeazytraining-vnic" {
  name                = "my-eazytraining-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "my-eazytraining-nic-ip"
    subnet_id                     = azurerm_subnet.tfeazytraining-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfeazytraining-ip.id
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}

resource "azurerm_network_interface_security_group_association" "tfeazytraining-assoc" {
  network_interface_id      = azurerm_network_interface.tfeazytraining-vnic.id
  network_security_group_id = azurerm_network_security_group.tfeazytraining-nsg.id
}

resource "azurerm_linux_virtual_machine" "tfeazytraining-vm" {
  name                            = "my-eazytraining-vm"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.tfeazytraining-vnic.id]
  size                            = var.instance_template
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = data.azurerm_platform_image.eazytraining-image.publisher
    offer     = data.azurerm_platform_image.eazytraining-image.offer
    sku       = data.azurerm_platform_image.eazytraining-image.sku
    version   = data.azurerm_platform_image.eazytraining-image.version
  }

  os_disk {
    name                 = "my-eazytraining-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}

