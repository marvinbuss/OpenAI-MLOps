resource "azurerm_cognitive_account" "cognitive_service_openai" {
  name                = "${local.prefix}-cog001"
  location            = var.location
  resource_group_name = azurerm_resource_group.cognitive_service_rg.name
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }

  custom_subdomain_name = "${local.prefix}-cog001"
  customer_managed_key {
    identity_client_id = ""
    key_vault_key_id   = ""
  }
  dynamic_throttling_enabled = true
  fqdns                      = []
  kind                       = "OpenAI"
  local_auth_enabled         = false
  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }
  outbound_network_access_restricted = true
  public_network_access_enabled      = false
  sku_name                           = "S0"
}

# resource "azurerm_cognitive_account_customer_managed_key" "cognitive_service_openai_cmk" {  # Uncomment to use customer managed keys for encryption
#   cognitive_account_id = azurerm_cognitive_account.cognitive_service_openai.id
#   key_vault_key_id = azurerm_key_vault_key.key_vault_cmk.id
# }

resource "azapi_resource" "cognitive_service_openai_model_deployment" {
  for_each  = var.cognitive_service_openai_model_configurations
  type      = "Microsoft.CognitiveServices/accounts/deployments@2022-12-01"
  name      = each.value.display_name
  parent_id = azurerm_cognitive_account.cognitive_service.id

  body = jsonencode({
    properties = {
      model = {
        format  = "OpenAI"
        name    = each.value.name
        version = each.value.version
      }
      scaleSettings = {
        scaleType = "Standard"
      }
    }
  })
}

resource "azurerm_private_endpoint" "purview_private_endpoint_portal" {
  name                = "${azurerm_cognitive_account.cognitive_service.name}-pe"
  location            = var.location
  resource_group_name = azurerm_cognitive_account.cognitive_service.resource_group_name
  tags                = var.tags

  custom_network_interface_name = "${azurerm_cognitive_account.cognitive_service.name}-nic"
  private_service_connection {
    name                           = "${azurerm_cognitive_account.cognitive_service.name}-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.cognitive_service.id
    subresource_names              = ["account"]
  }
  subnet_id = azurerm_subnet.private_endpoint_subnet.id
  dynamic "private_dns_zone_group" {
    content {
      name = "${azurerm_cognitive_account.cognitive_service.name}-arecord"
      private_dns_zone_ids = [
        azurerm_private_dns_zone.private_dns_zone_id_cognitive_service_openai.id
      ]
    }
  }
}
