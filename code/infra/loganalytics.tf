resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${local.prefix}-log001"
  location            = var.location
  resource_group_name = azurerm_resource_group.cognitive_service_rg.name
  tags                = var.tags

  daily_quota_gb                     = -1
  internet_ingestion_enabled         = true
  internet_query_enabled             = false
  reservation_capacity_in_gb_per_day = 100
  retention_in_days                  = 30
  sku                                = "PerGB2018"
}
