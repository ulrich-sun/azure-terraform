data "azurerm_platform_image" "eazytraining-image" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts"
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tfeazytraining-vm" {
  name                            = "my-eazytraining-vm"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [var.network_interface_id]
  size                            = var.instance_template
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
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
    host     = self.public_ip_address
  }

  tags = {
    environment = "my-eazytraining-env"
  }
}
