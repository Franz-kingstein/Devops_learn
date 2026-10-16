# Terraform configuration for Azure provider
# Using azurerm provider version 4.x (latest major version)
# Pin to ~> 4.0 to get latest 4.x patches without breaking changes

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend configuration will be in backend.tf
  # Uncomment and configure for remote state storage
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatestorageacct"
  #   container_name       = "tfstate"
  #   key                  = "devops-ia3/terraform.tfstate"
  # }
}

# Configure the Azure provider
# Uses Azure CLI authentication (az login) or service principal via env vars
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # Optional: Skip provider registration if not permitted
  # skip_provider_registration = true
}