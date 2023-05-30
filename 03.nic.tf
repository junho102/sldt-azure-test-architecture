# Create network interface(bastion)
resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.prefix}-bastion-nic"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name

  ip_configuration {
    name                          = "${var.prefix}-nic-configuration"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

# Connect the security group to the network interface(bastion)
resource "azurerm_network_interface_security_group_association" "bastion_nic_sg_asso" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}


# Create network interface(vault)
resource "azurerm_network_interface" "vault_nic" {
  count               = length(local.vault_vm_num)
  name                = "${var.prefix}-vault${count.index+1}-nic"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name

  ip_configuration {
    name                          = "${var.prefix}-nic-configuration"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface(vault)
resource "azurerm_network_interface_security_group_association" "vault_nic_sg_asso" {
  count                     = length(local.vault_vm_num)
  network_interface_id      = azurerm_network_interface.vault_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.vault_nsg.id
}