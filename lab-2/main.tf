# Resource Group
resource "azurerm_resource_group" "tfeazytraining-gp" {
  name     = "my-eazytraining-rg"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "tfeazytraining-vnet" {
  name                = "my-eazytraining-vnet"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Subnet
resource "azurerm_subnet" "tfeazytraining-subnet" {
  name                 = "my-eazytraining-subnet"
  resource_group_name  = azurerm_resource_group.tfeazytraining-gp.name
  virtual_network_name = azurerm_virtual_network.tfeazytraining-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "tfeazytraining-ip" {
  name                = "my-eazytraining-public-ip"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Network Security Group
resource "azurerm_network_security_group" "tfeazytraining-nsg" {
  name                = "my-eazytraining-nsg"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name

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

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Network Interface
resource "azurerm_network_interface" "tfeazytraining-vnic" {
  name                = "my-eazytraining-nic"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name

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

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "tfeazytraining-assoc" {
  network_interface_id      = azurerm_network_interface.tfeazytraining-vnic.id
  network_security_group_id = azurerm_network_security_group.tfeazytraining-nsg.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "tfeazytraining-vm" {
  name                            = "my-eazytraining-vm"
  location                        = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name             = azurerm_resource_group.tfeazytraining-gp.name
  network_interface_ids           = [azurerm_network_interface.tfeazytraining-vnic.id]
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
    name                 = "my-eazytraining-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}
