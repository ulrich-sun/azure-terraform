resource "azurerm_resource_group" "eazy-rg" {
  name     = "my-eazy-rg"
  location = "West Europe"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "eazy-vnet" {
  name                = "my-eazy-vnet"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazy-env"
  }

  depends_on = [azurerm_resource_group.eazy-rg] # Assure que le réseau virtuel dépend du groupe de ressources
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "eazy-subnet" {
  name                 = "my-eazy-subnet"
  resource_group_name  = azurerm_resource_group.eazy-rg.name
  virtual_network_name = azurerm_virtual_network.eazy-vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.eazy-vnet] # Assure que le sous-réseau dépend du réseau virtuel
}

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "eazy-nsg" {
  name                = "my-eazy-nsg"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

  tags = {
    environment = "my-eazy-env"
  }

  depends_on = [azurerm_resource_group.eazy-rg] # Assure que le NSG dépend du groupe de ressources
}

# Create a Public IP for the Network Interface
resource "azurerm_public_ip" "eazy" {
  name                = "my-eazy-public-ip"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  depends_on = [azurerm_resource_group.eazy-rg] # Assure que l'IP publique dépend du groupe de ressources
}

# Create a Network Interface
resource "azurerm_network_interface" "eazy-vnic" {
  name                = "my-eazy-nic"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

  ip_configuration {
    name                          = "my-eazy-nic-ip"
    subnet_id                     = azurerm_subnet.eazy-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.eazy.id
  }

  tags = {
    environment = "my-eazy-env"
  }

  depends_on = [azurerm_subnet.eazy-subnet, azurerm_public_ip.eazy] # Assure que l'interface réseau dépend du sous-réseau et de l'IP publique
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "eazy-assoc" {
  network_interface_id      = azurerm_network_interface.eazy-vnic.id
  network_security_group_id = azurerm_network_security_group.eazy-nsg.id

  depends_on = [azurerm_network_interface.eazy-vnic, azurerm_network_security_group.eazy-nsg] # Assure l'association entre NSG et NIC
}

# Create a Virtual Machine
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-eazy-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "my-eazy-env"
  }

  depends_on = [azurerm_network_interface.eazy-vnic] # Assure que la VM dépend de l'interface réseau
}
