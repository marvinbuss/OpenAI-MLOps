terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.8.0"
    }
  }

  backend "azurerm" {
    environment          = "public"
    resource_group_name  = "terraform"
    storage_account_name = "terraformptt001"
    container_name       = "tfstate"
    key                  = "terraform.data-landing-zone.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  disable_correlation_request_id = false
  environment                    = "public"
  skip_provider_registration     = false
  storage_use_azuread            = true
  use_oidc                       = true

  features {
    key_vault {
      recover_soft_deleted_key_vaults   = true
      recover_soft_deleted_certificates = true
      recover_soft_deleted_keys         = true
      recover_soft_deleted_secrets      = true
    }
    network {
      relaxed_locking = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azapi" {
  default_location               = var.location
  default_tags                   = var.tags
  disable_correlation_request_id = false
  environment                    = "public"
  skip_provider_registration     = false
  use_oidc                       = true
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "cognitive_service_rg" {
  name     = "${local.prefix}-cognitive-service-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "logging_rg" {
  name     = "${local.prefix}-logging-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "dns_rg" {
  name     = "${local.prefix}-dns-rg"
  location = var.location
  tags     = var.tags
}
