resource "azurerm_resource_group" "tfeazytraining-gp" {
  name     = "my-eazytraining-rg"
  location = "West Europe"
}

# Public IPs
resource "azurerm_public_ip" "tfeazytraining-ip" {
  count               = 3
  name                = "my-eazytraining-public-ip-${count.index}"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Network Interfaces
resource "azurerm_network_interface" "tfeazytraining-vnic" {
  count               = 3
  name                = "my-eazytraining-nic-${count.index}"
  location            = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp.name

  ip_configuration {
    name                          = "my-eazytraining-nic-ip-${count.index}"
    subnet_id                     = azurerm_subnet.tfeazytraining-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfeazytraining-ip[count.index].id
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}

# NSG association
resource "azurerm_network_interface_security_group_association" "tfeazytraining-assoc" {
  count                      = 3
  network_interface_id      = azurerm_network_interface.tfeazytraining-vnic[count.index].id
  network_security_group_id = azurerm_network_security_group.tfeazytraining-nsg.id
}

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "tfeazytraining-vm" {
  count                           = 3
  name                            = "my-eazytraining-vm-${count.index}"
  location                        = azurerm_resource_group.tfeazytraining-gp.location
  resource_group_name             = azurerm_resource_group.tfeazytraining-gp.name
  network_interface_ids           = [azurerm_network_interface.tfeazytraining-vnic[count.index].id]
  size                            = "Standard_B1s"
  computer_name                   = "myvm-${count.index}"
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
    name                 = "my-eazytraining-os-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}
