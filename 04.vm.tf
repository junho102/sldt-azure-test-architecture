###################### bastion VM ######################
########################################################

# DNS record by another resource Prevent already reserved
resource "random_id" "bastion_pip" {
  byte_length = 4
}

# Create public IPs
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-bastion-pip-${random_id.bastion_pip.hex}"
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "${var.prefix}-bastion-vm"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  size                = var.vm_size[0]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_username      = var.vm_username
  computer_name       = "bastion"

  admin_ssh_key {
    username   = var.vm_username
    public_key = file("sshkey/sldt_rsa.pub")
  }

  tags = {
    Name        = "${var.prefix}-bastion-vm"
    environment = var.environment
  }

  # Added VM destroy first and then nic destroy to work correctly.
  depends_on = [azurerm_network_interface_security_group_association.bastion_nic_sg_asso]
}


####################### vault VM #######################
########################################################

resource "azurerm_linux_virtual_machine" "vault" {
  count                 = length(local.vault_vm_num)
  name                  = "${var.prefix}-vault${count.index+1}-vm"
  location              = azurerm_resource_group.sldt_rg.location
  resource_group_name   = azurerm_resource_group.sldt_rg.name
  network_interface_ids = [azurerm_network_interface.vault_nic[count.index].id]
  size                  = var.vm_size[0]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_username      = var.vm_username
  computer_name       = "vault${count.index+1}"

  admin_ssh_key {
    username   = var.vm_username
    public_key = file("sshkey/sldt_rsa.pub")
  }

  tags = {
    Name        = "${var.prefix}-vault${count.index+1}-vm"
    environment = var.environment
  }

  # Added VM destroy first and then nic destroy to work correctly.
  depends_on = [azurerm_network_interface_security_group_association.vault_nic_sg_asso]
}

