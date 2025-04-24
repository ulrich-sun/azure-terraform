output "vm_id" {
  value = azurerm_linux_virtual_machine.tfeazytraining-vm.id
}

output "availability_zone" {
  value = azurerm_linux_virtual_machine.tfeazytraining-vm.location
}

resource "null_resource" "write_info" {
  depends_on = [azurerm_linux_virtual_machine.tfeazytraining-vm]

  provisioner "local-exec" {
    command = <<-EOT
      echo "IP: ${azurerm_network_interface.tfeazytraining-vnic.ip_configuration[0].public_ip_address_id}" > infos_vm.txt
      echo "ID: ${azurerm_linux_virtual_machine.tfeazytraining-vm.id}" >> infos_vm.txt
      echo "Zone de disponibilité: ${azurerm_linux_virtual_machine.tfeazytraining-vm.location}" >> infos_vm.txt
    EOT
  }
}
