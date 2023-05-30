resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.sldt_rg.name
  location                 = azurerm_resource_group.sldt_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Name        = "${var.prefix}-storage-account"
    environment = var.environment
  }

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.private_subnet.id]
  }
}

resource "azurerm_storage_container" "stc" {
  name                  = var.azurerm_storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.container_access_type
}
