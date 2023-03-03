resource "azurerm_private_dns_zone" "private_dns_zone_id_cognitive_service_openai" {
  name                = "privatelink.openai.azure.com"
  location            = var.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_id_cognitive_service_link" {
  name                = azurerm_private_dns_zone.private_dns_zone_id_cognitive_service.name
  resource_group_name = azurerm_private_dns_zone.private_dns_zone_id_cognitive_service.resource_group_name
  tags                = var.tags

  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_id_cognitive_service.name
  registration_enabled  = false
  virtual_network_id    = data.azurerm_virtual_network.virtual_network.id
}

resource "azurerm_private_dns_zone" "private_dns_zone_id_blob" {
  name                = "privatelink.blob.core.windows.net"
  location            = var.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_id_blob_link" {
  name                = azurerm_private_dns_zone.private_dns_zone_id_blob.name
  resource_group_name = azurerm_private_dns_zone.private_dns_zone_id_blob.resource_group_name
  tags                = var.tags

  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_id_blob.name
  registration_enabled  = false
  virtual_network_id    = data.azurerm_virtual_network.virtual_network.id
}

resource "azurerm_private_dns_zone" "private_dns_zone_id_vault" {
  name                = "privatelink.vaultcore.azure.net"
  location            = var.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_id_vault_link" {
  name                = azurerm_private_dns_zone.private_dns_zone_id_vault.name
  resource_group_name = azurerm_private_dns_zone.private_dns_zone_id_vault.resource_group_name
  tags                = var.tags

  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone_id_vault.name
  registration_enabled  = false
  virtual_network_id    = data.azurerm_virtual_network.virtual_network.id
}
