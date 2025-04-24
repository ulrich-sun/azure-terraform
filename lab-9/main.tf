locals {
  regions = {
    eastus  = "rg-eastus"
    eastus2 = "rg-eastus2"
    westus  = "rg-westus"
  }
}

resource "azurerm_resource_group" "tfeazytraining-gp" {
  for_each = local.regions
  name     = each.value
  location = each.key
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tfeazytraining-vnet" {
  for_each            = local.regions
  name                = "my-eazytraining-vnet${each.key}"
  location            = azurerm_resource_group.tfeazytraining-gp[each.key].location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp[each.key].name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tfeazytraining-subnet" {
  for_each            = local.regions
  name                 = "my-eazytraining-subnet"
  resource_group_name  = azurerm_resource_group.tfeazytraining-gp[each.key].name
  virtual_network_name = azurerm_virtual_network.tfeazytraining-vnet[each.key].name
  address_prefixes     = ["10.0.2.0/24"]
}


# Create a Network Security Group and rule
resource "azurerm_network_security_group" "tfeazytraining-nsg" {
  for_each = local.regions
  name                = "my-eazytraining-nsg-${each.key}"
  location            = azurerm_resource_group.tfeazytraining-gp[each.key].location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp[each.key].name

  tags = {
    environment = "my-eazytraining-env"
  }
}

resource "azurerm_public_ip" "tfeazytraining" {
  for_each = local.regions
  name                = "my-eazytraining-public-ip-${each.key}"
  location            = azurerm_resource_group.tfeazytraining-gp[each.key].location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp[each.key].name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "my-eazytraining-region-${each.key}"
  }
}

# Create a Network Interface
resource "azurerm_network_interface" "tfeazytraining-vnic" {
  for_each = local.regions
  name                = "my-eazytraining-nic"
  location            = azurerm_resource_group.tfeazytraining-gp[each.key].location
  resource_group_name = azurerm_resource_group.tfeazytraining-gp[each.key].name

  ip_configuration {
    name                          = "my-eazytraining-nic-ip"
    subnet_id                     = azurerm_subnet.tfeazytraining-subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfeazytraining[each.key].id
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "tfeazytraining-assoc" {
  for_each = local.regions
  network_interface_id      = azurerm_network_interface.tfeazytraining-vnic[each.key].id
  network_security_group_id = azurerm_network_security_group.tfeazytraining-nsg[each.key].id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tfeazytraining-vm" {
  for_each = local.regions
  name                            = "my-eazytraining-vm"
  location                        = azurerm_resource_group.tfeazytraining-gp[each.key].location
  resource_group_name             = azurerm_resource_group.tfeazytraining-gp[each.key].name
  network_interface_ids           = [azurerm_network_interface.tfeazytraining-vnic[each.key].id]
  size                            = "Standard_B1s"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
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

