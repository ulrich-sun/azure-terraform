resource "azurerm_resource_group" "tfeazytrainingd-gp" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tfeazytrainingd-vnet" {
  name                = "my-eazytrainingd-vnet"
  location            = azurerm_resource_group.tfeazytrainingd-gp.location
  resource_group_name = azurerm_resource_group.tfeazytrainingd-gp.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-eazytrainingd-env"
  }
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tfeazytrainingd-subnet" {
  name                 = "my-eazytrainingd-subnet"
  resource_group_name  = azurerm_resource_group.tfeazytrainingd-gp.name
  virtual_network_name = azurerm_virtual_network.tfeazytrainingd-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Public IP
resource "azurerm_public_ip" "tfeazytrainingd-ip" {
  name                = "my-eazytrainingd-public-ip"
  location            = azurerm_resource_group.tfeazytrainingd-gp.location
  resource_group_name = azurerm_resource_group.tfeazytrainingd-gp.name
  allocation_method   = "Static"

  tags = {
    environment = "my-eazytrainingd-env"
  }
}

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "tfeazytrainingd-nsg" {
  name                = "my-eazytrainingd-nsg"
  location            = azurerm_resource_group.tfeazytrainingd-gp.location
  resource_group_name = azurerm_resource_group.tfeazytrainingd-gp.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1000
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
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_server_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "my-eazytrainingd-env"
  }
}

# Create a Network Interface
resource "azurerm_network_interface" "tfeazytrainingd-vnic" {
  name                = "my-eazytrainingd-nic"
  location            = azurerm_resource_group.tfeazytrainingd-gp.location
  resource_group_name = azurerm_resource_group.tfeazytrainingd-gp.name

  ip_configuration {
    name                          = "my-eazytrainingd-nic-ip"
    subnet_id                     = azurerm_subnet.tfeazytrainingd-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfeazytrainingd-ip.id
  }

  tags = {
    environment = "my-eazytrainingd-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "tfeazytrainingd-assoc" {
  network_interface_id      = azurerm_network_interface.tfeazytrainingd-vnic.id
  network_security_group_id = azurerm_network_security_group.tfeazytrainingd-nsg.id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tfeazytrainingd-vm" {
  name                            = "my-eazytrainingd-vm"
  location                        = azurerm_resource_group.tfeazytrainingd-gp.location
  resource_group_name             = azurerm_resource_group.tfeazytrainingd-gp.name
  network_interface_ids           = [azurerm_network_interface.tfeazytrainingd-vnic.id]
  size                            = var.instance_template
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = data.azurerm_platform_image.eazytrainingd-image.publisher
    offer     = data.azurerm_platform_image.eazytrainingd-image.offer
    sku       = data.azurerm_platform_image.eazytrainingd-image.sku
    version   = data.azurerm_platform_image.eazytrainingd-image.version
  }


  os_disk {
    name                 = "my-eazytrainingd-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  provisioner "file" {
    source      = "scripts/install.sh"              # fichier local
    destination = "/home/azureuser/install.sh"      # chemin distant
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/azureuser/install.sh",
      "sudo /home/azureuser/install.sh"
    ]
  }

  connection {
    type     = "ssh"
    user     = "azureuser"
    password = "Password1234!"
    host     = azurerm_public_ip.tfeazytrainingd-ip.ip_address
  }

  tags = {
    environment = "my-eazytrainingd-env"
  }
}

resource "azurerm_storage_account" "eazytrainingd-sa" {
  #name                     = "storage-account-azure-votreprenom-eazytrainingd"
  name                     = "eazytrainingdstorage23"
  resource_group_name      = azurerm_resource_group.tfeazytrainingd-gp.name
  location                 = azurerm_resource_group.tfeazytrainingd-gp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "eazytrainingd-container" {
  name                  = "eazytrainingd-container"
  storage_account_name  = azurerm_storage_account.eazytrainingd-sa.name
  container_access_type = "private"
}

