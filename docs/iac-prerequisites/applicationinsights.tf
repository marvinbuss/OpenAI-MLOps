resource "azurerm_application_insights" "application_insights" {
  name                = "${local.prefix}-ai001"
  location            = var.location
  resource_group_name = azurerm_resource_group.logging_rg.name
  tags                = var.tags

  application_type                      = "other"
  daily_data_cap_in_gb                  = 10
  daily_data_cap_notifications_disabled = false
  disable_ip_masking                    = false
  force_customer_storage_for_profiler   = false
  internet_ingestion_enabled            = true
  internet_query_enabled                = false
  local_authentication_disabled         = true
  retention_in_days                     = 30
  sampling_percentage                   = 100
  workspace_id                          = azurerm_log_analytics_workspace.log_analytics.id
}
