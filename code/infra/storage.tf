resource "azurerm_storage_account" "storage" {
  name                = replace("${local.prefix}-st001")
  location            = var.location
  resource_group_name = azurerm_resource_group.cognitive_service_rg.name
  tags                = var.tags

  access_tier                     = "Hot"
  account_kind                    = "Standard"
  account_replication_type        = "ZRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  allowed_copy_scope              = "AAD"
  blob_properties {
    change_feed_enabled           = false
    change_feed_retention_in_days = 7
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
    default_service_version  = "2022-09-01"
    last_access_time_enabled = false
    versioning_enabled       = false
  }
  cross_tenant_replication_enabled = false
  default_to_oauth_authentication  = true
  enable_https_traffic_only        = true
  immutability_policy {
    state                         = "Disabled"
    allow_protected_append_writes = true
    period_since_creation_in_days = 7
  }
  infrastructure_encryption_enabled = true
  is_hns_enabled                    = false
  large_file_share_enabled          = false
  min_tls_version                   = "TLS1_2"
  network_rules {
    bypass                     = ["None"]
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  nfsv3_enabled                 = false
  public_network_access_enabled = false
  queue_encryption_key_type     = "Service"
  table_encryption_key_type     = "Service"
  routing {
    choice                      = "MicrosoftRouting"
    publish_internet_endpoints  = false
    publish_microsoft_endpoints = false
  }
  sftp_enabled              = false
  shared_access_key_enabled = false
}

resource "azurerm_storage_management_policy" "storage_management_policy" {
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "default"
    enabled = true
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 360
        # delete_after_days_since_modification_greater_than = 720
      }
      snapshot {
        change_tier_to_cool_after_days_since_creation = 180
        delete_after_days_since_creation_greater_than = 360
      }
      version {
        change_tier_to_cool_after_days_since_creation = 180
        delete_after_days_since_creation              = 360
      }
    }
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = []
    }
  }
}

# resource "azurerm_storage_container" "storage_containers" {  # Requires private connectivity as this does not use the ARM API
#   for_each             = local.storage_container_names
#   name                 = each.key
#   storage_account_name = azurerm_storage_account.storage.name

#   container_access_type = "private"
# }

resource "azapi_resource" "storage_containers" {
  for_each  = local.storage_container_names
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01"
  name      = each.key
  parent_id = "${azurerm_storage_account.datalake.id}/blobServices/default"

  body = jsonencode({
    properties = {
      publicAccess = "None"
      metadata     = {}
    }
  })
}

# resource "azurerm_storage_account_customer_managed_key" "storage_cmk" {  # Uncomment to use customer managed keys for encryption
#   storage_account_id = azurerm_storage_account.storage.id
#   key_vault_id = azurerm_key_vault.key_vault.id
#   key_name = azurerm_key_vault_key.key_vault_cmk.name
# }

resource "azurerm_private_endpoint" "storage_private_endpoint_blob" {
  name                = "${azurerm_storage_account.storage.name}-blob-pe"
  location            = var.location
  resource_group_name = azurerm_storage_account.storage.resource_group_name
  tags                = var.tags

  custom_network_interface_name = "${azurerm_storage_account.storage.name}-blob-nic"
  private_service_connection {
    name                           = "${azurerm_storage_account.storage.name}-blob-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
  }
  subnet_id = var.subnet_id
  dynamic "private_dns_zone_group" {
    content {
      name = "${azurerm_storage_account.storage.name}-blob-arecord"
      private_dns_zone_ids = [
        azurerm_private_dns_zone.private_dns_zone_id_blob.id
      ]
    }
  }
}
