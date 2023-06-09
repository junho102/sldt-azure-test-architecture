resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.sldt_rg.name
  location            = azurerm_resource_group.sldt_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}
