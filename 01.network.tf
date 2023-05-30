# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.sldt_rg.location
  address_space       = [var.address_space]
  resource_group_name = azurerm_resource_group.sldt_rg.name
}

# Create subnet
resource "azurerm_subnet" "public_subnet" {
  name                 = "${var.prefix}-pub-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.sldt_rg.name
  address_prefixes     = [var.pub_subnet_prefix]

  service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.prefix}-pri-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.sldt_rg.name
  address_prefixes     = [var.pri_subnet_prefix]

  service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

