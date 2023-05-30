# DNS record by another resource Prevent already reserved
resource "random_id" "lb_pip" {
  byte_length = 4
}

# Manages a Load Balancer Resource.
resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.prefix}-lb-pip"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-lb-pip-${random_id.bastion_pip.hex}"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-vault-lb"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# Manages a Load Balancer Backend Address Pool.
resource "azurerm_lb_backend_address_pool" "lb_be_pool" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "be_pool_asso_vault_nic" {
  count = length(local.vault_vm_num)
  network_interface_id    = azurerm_network_interface.vault_nic[count.index].id
  ip_configuration_name   = "${var.prefix}-nic-configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_be_pool.id
}

# Manages a LoadBalancer Probe Resource.
resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "vault-probe"
  protocol        = "Http"
  port            = 8200
  request_path    = "/v1/sys/health?performancestandbycode=200"
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_inbound_rule" {
  name               = "vault-lb-inbound-rule"
  loadbalancer_id    = azurerm_lb.lb.id
  protocol           = "Tcp"
  frontend_port      = 8200
  backend_port       = 8200
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_be_pool.id]
  probe_id           = azurerm_lb_probe.lb_probe.id
  frontend_ip_configuration_name = "PublicIPAddress"
}