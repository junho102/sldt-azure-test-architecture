# Create Network Security Group and rule(bastion)
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.prefix}-bastion-nsg"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Security Group and rule(vault)
resource "azurerm_network_security_group" "vault_nsg" {
  name                = "${var.prefix}-vault-nsg"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name

  security_rule {
    name                       = "vault_server_allow_inbound_8200"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vault_server_allow_inbound_8201"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8201"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vault_server_allow_inbound_22"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"#"Deny"
    protocol                   = "Tcp"
    source_address_prefix      = var.pub_subnet_prefix
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}