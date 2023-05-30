resource "azurerm_resource_group" "sldt_rg" {
  name     = "${var.prefix}-rg"
  location = "${var.region}"
}