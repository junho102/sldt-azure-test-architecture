resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.prefix}-${var.environment}-aks"
  location = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.dns_prefix
  
  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = var.vm_size[2]
  }

  # cluster에 대한 작업을 위해 인증 정보 설정
  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }
}