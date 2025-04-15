output "public_ip" {
  value = azurerm_network_interface.example.ip_configuration[0].public_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.example.id
}

output "availability_zone" {
  value = azurerm_linux_virtual_machine.example.availability_zone
}

resource "null_resource" "write_info" {
  depends_on = [azurerm_linux_virtual_machine.example]

  provisioner "local-exec" {
    command = <<-EOT
      echo "IP: ${azurerm_network_interface.example.ip_configuration[0].public_ip_address}" > infos_ec2.txt
      echo "ID: ${azurerm_linux_virtual_machine.example.id}" >> infos_ec2.txt
      echo "Zone de disponibilité: ${azurerm_linux_virtual_machine.example.availability_zone}" >> infos_ec2.txt
    EOT
  }
}
