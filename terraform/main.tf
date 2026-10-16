# Root module - calls network and compute modules
# This is the main entry point for Terraform configuration

# Merge common tags with project-specific tags
locals {
  tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      owner       = var.owner
      managed_by  = "terraform"
    },
    var.common_tags
  )

  # Generate unique resource names
  resource_prefix = "${var.project_name}-${var.environment}"
}

# Network Module
# Creates: Resource Group, Virtual Network, Subnet, NSG with rules
module "network" {
  source = "./modules/network"

  location            = var.location
  resource_group_name = "${local.resource_prefix}-rg"
  vnet_name           = "${local.resource_prefix}-vnet"
  subnet_name         = "${local.resource_prefix}-subnet"
  nsg_name            = "${local.resource_prefix}-nsg"
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24"]
  allowed_ssh_cidrs   = var.allowed_ssh_cidrs
  allowed_http_cidrs  = var.allowed_http_cidrs
  tags                = local.tags
}

# Compute Module
# Creates: Public IP, Network Interface, Linux VM with cloud-init
module "compute" {
  source = "./modules/compute"

  # Depends on network module outputs
  location            = var.location
  resource_group_name = module.network.resource_group_name
  subnet_id           = module.network.subnet_id
  nsg_id              = module.network.nsg_id

  vm_name         = "${local.resource_prefix}-vm"
  nic_name        = "${local.resource_prefix}-nic"
  public_ip_name  = "${local.resource_prefix}-pip"
  admin_username  = var.admin_username
  vm_size         = var.vm_size
  zone            = var.zone
  ssh_public_key  = file(pathexpand(var.ssh_public_key_path))
  app_version     = var.app_version
  github_repo_url = var.github_repo_url
  tags            = local.tags
}