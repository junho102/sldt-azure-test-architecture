data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "vault" {
  application_id = var.client_id
}

resource "random_id" "keyvault" {
  byte_length = 4
}

resource "azurerm_key_vault" "vault" {
  name                = "${var.prefix}-${var.environment}-vault-${random_id.keyvault.hex}"
  location            = azurerm_resource_group.sldt_rg.location
  resource_group_name = azurerm_resource_group.sldt_rg.name
  tenant_id           = var.tenant_id

  # enable virtual machines to access this key vault.
  enabled_for_deployment = true

  sku_name = "standard"

  tags = {
    environment = var.environment
  }

  # access policy for the hashicorp vault service principal.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azuread_service_principal.vault.object_id
    
    key_permissions = [
      "Get",
      "WrapKey",
      "UnwrapKey",
    ]
  }

  # access policy for the user that is currently running terraform.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
    ]
  }

  # TODO does this really need to be so broad? can it be limited to the vault vm?
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# hashicorp vault will use this azurerm_key_vault_key to wrap/encrypt its master key.
resource "azurerm_key_vault_key" "generated" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]
}