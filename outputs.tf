output "bastion_public_ip" {
  value = azurerm_linux_virtual_machine.bastion.public_ip_address
}

output "vault1_server_private_ip" {
  value = azurerm_linux_virtual_machine.vault[0].private_ip_address
}

output "vault2_server_private_ip" {
  value = azurerm_linux_virtual_machine.vault[1].private_ip_address
}

output "vault3_server_private_ip" {
  value = azurerm_linux_virtual_machine.vault[2].private_ip_address
}

output "ssh-addr" {
  value = <<SSH

    Connect to your bastion virtual machine via SSH:

    $ ssh -i {private key} ${var.vm_username}@${azurerm_linux_virtual_machine.bastion.public_ip_address}

SSH
}

output "vault_name" {
  value = azurerm_key_vault.vault.name
}

output "key_name" {
  value = azurerm_key_vault_key.generated.name
}