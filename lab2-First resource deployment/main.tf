# Resource Group
resource "azurerm_resource_group" "eazy-rg" {
  name     = "my-eazy-rg"
  location = "West Europe"
  tags = {
    environment = "my-eazy-env"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "eazy-vnet" {
  name                = "my-eazy-vnet"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazy-env"
  }
}

# Subnet
resource "azurerm_subnet" "eazy-subnet" {
  name                 = "my-eazy-subnet"
  resource_group_name  = azurerm_resource_group.eazy-rg.name
  virtual_network_name = azurerm_virtual_network.eazy-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "eazy-ip" {
  name                = "my-eazy-public-ip"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  allocation_method   = "Dynamic"
  sku = "Basic"

  tags = {
    environment = "my-eazy-env"
  }
}

# Network Security Group
resource "azurerm_network_security_group" "eazy-nsg" {
  name                = "my-eazy-nsg"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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

# Network Interface
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

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "eazy-assoc" {
  network_interface_id      = azurerm_network_interface.eazy-vnic.id
  network_security_group_id = azurerm_network_security_group.eazy-nsg.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "eazy-vm" {
  name                            = "my-eazy-vm"
  location                        = azurerm_resource_group.eazy-rg.location
  resource_group_name             = azurerm_resource_group.eazy-rg.name
  network_interface_ids           = [azurerm_network_interface.eazy-vnic.id]
  size                            = "Standard_B1s"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "my-eazy-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_network_watcher" "example" {
  name                = "my-eazy-watcher"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  tags = {
    environment = "my-eazy-env" 
  }
}
