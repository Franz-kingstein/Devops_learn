# Backend configuration for Terraform state
# Uncomment and configure one of the following backends for team collaboration

# Option 1: Azure Storage Backend (recommended for Azure)
# Prerequisites:
# 1. Create a storage account and container:
#    az group create -n tfstate-rg -l eastus
#    az storage account create -n tfstatestorageacct -g tfstate-rg -l eastus --sku Standard_LRS --kind StorageV2
#    az storage container create -n tfstate --account-name tfstatestorageacct
# 2. Run: terraform init -migrate-state
#
# backend "azurerm" {
#   resource_group_name  = "tfstate-rg"
#   storage_account_name = "tfstatestorageacct"
#   container_name       = "tfstate"
#   key                  = "devops-ia3/terraform.tfstate"
# }

# Option 2: Local Backend (default, for solo development)
# State file stored in .terraform/terraform.tfstate locally
# No configuration needed - this is the default

# Option 3: Terraform Cloud / HCP Terraform
# backend "remote" {
#   organization = "your-org"
#   workspaces {
#     name = "devops-ia3"
#   }
# }

# Note: After changing backend, run:
#   terraform init -migrate-state
# to migrate existing state