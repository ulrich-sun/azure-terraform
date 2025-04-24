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
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "eazy-subnet" {
  name                 = "my-eazy-subnet"
  resource_group_name  = azurerm_resource_group.eazy-rg.name
  virtual_network_name = azurerm_virtual_network.eazy-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Public IP
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

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "my-eazy-nsg"
  location            = azurerm_resource_group.eazy-rg.location
  resource_group_name = azurerm_resource_group.eazy-rg.name

  dynamic "security_rule" {
    for_each = var.allowed_ports
    content {
      name                       = "Allow-Port-${security_rule.value}"
      priority                   = 100 + index(var.allowed_ports, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "${security_rule.value}"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  lifecycle {
    prevent_destroy = false
  }
   tags = {
    environment = "my-eazy-env"
  }
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
    public_ip_address_id          = azurerm_public_ip.eazy-ip.id
  }

  tags = {
    environment = "my-eazy-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "eazy-assoc" {
  network_interface_id      = azurerm_network_interface.eazy-vnic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "eazy-vm" {
  name                            = "my-eazy-vm"
  location                        = azurerm_resource_group.eazy-rg.location
  resource_group_name             = azurerm_resource_group.eazy-rg.name
  network_interface_ids           = [azurerm_network_interface.eazy-vnic.id]
  size                            = var.instance_template
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
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
   provisioner "local-exec" {
     command = "echo ${azurerm_linux_virtual_machine.eazy-vm.name}:  ${azurerm_public_ip.eazy-ip.ip_address} >> ip_address.txt"
	}
	
  tags = {
    environment = "my-eazy-env"
  }
}

resource "azurerm_virtual_machine_extension" "vm-extension" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.eazy-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
      "commandToExecute": "sudo apt-get install -y nginx ; sudo systemctl enable --now nginx"
    }
  SETTINGS

  tags = {
    environment = "my-terraform-env"
  }
}