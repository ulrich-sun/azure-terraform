resource "azurerm_resource_group" "eazy-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_watcher" "eazy-watcher" {
  name                = "my-eazy-watcher"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_virtual_network" "eazy-vnet" {
  name                = "my-eazy-vnet"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_subnet" "eazy-subnet" {
  name                 = "my-eazy-subnet"
  resource_group_name  = azurerm_resource_group.eazy-rg.name
  virtual_network_name = azurerm_virtual_network.eazy-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "eazy-ip" {
  name                = "my-eazy-public-ip"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_network_security_group" "eazy-nsg" {
  name                = "my-eazy-nsg"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

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
  lifecycle {
    prevent_destroy = false
  }
  
  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_network_interface" "eazy-vnic" {
  name                = "my-eazy-nic"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

  ip_configuration {
    name                          = "my-eazy-nic-ip"
    subnet_id                     = azurerm_subnet.eazy-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.eazy-ip.id
  }

  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_network_interface_security_group_association" "eazy-assoc" {
  network_interface_id      = azurerm_network_interface.eazy-vnic.id
  network_security_group_id = azurerm_network_security_group.eazy-nsg.id
}

resource "azurerm_linux_virtual_machine" "eazy-vm" {
  name                            = "my-eazy-vm"
  location                        = azurerm_resource_group.eazy-rg.location
  resource_group_name             = azurerm_resource_group.eazy-rg.name
  network_interface_ids           = [azurerm_network_interface.eazy-vnic.id]
  size                            = var.instance_template
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = data.azurerm_platform_image.eazy-image.publisher
    offer     = data.azurerm_platform_image.eazy-image.offer
    sku       = data.azurerm_platform_image.eazy-image.sku
    version   = data.azurerm_platform_image.eazy-image.version
  }

  os_disk {
    name                 = "my-eazy-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_storage_account" "eazy-sa" {
  name                     = "eazystorage23"
  resource_group_name      = azurerm_resource_group.eazy-rg.name
  location                 = azurerm_resource_group.eazy-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "eazy-container" {
  name                  = "eazy-container"
  storage_account_id    = azurerm_storage_account.eazy-sa.id
  container_access_type = "private"
}
