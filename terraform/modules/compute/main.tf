# Compute Module - Azure Virtual Machine Resources
# Creates: SSH key pair (if not provided), Public IP, NIC, Linux VM with cloud-init

# Generate SSH key pair if not provided via variable
resource "tls_private_key" "ssh_key" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Use provided SSH public key or generated one
locals {
  ssh_public_key  = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh_key[0].public_key_openssh
  ssh_private_key = var.ssh_public_key != "" ? "" : tls_private_key.ssh_key[0].private_key_pem
}

# Static Public IP with DNS label
resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [var.zone]
  # Optional DNS label for FQDN (must be globally unique)
  # domain_name_label = var.vm_name
  tags = var.tags
}

# Network Interface connecting VM to subnet
resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  tags                  = var.tags
  zone                  = var.zone

  # Disable password authentication - SSH key only
  disable_password_authentication = true

  # Admin SSH key configuration
  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  # OS Disk configuration
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  # Source image: Ubuntu 22.04 LTS (gen2)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Cloud-init custom data for VM initialization
  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    admin_username  = var.admin_username
    app_version     = var.app_version
    github_repo_url = var.github_repo_url
  }))

  # Optional: Enable managed identity for Azure resource access
  # identity {
  #   type = "SystemAssigned"
  # }
}

# Output the public IP address
output "public_ip_address" {
  description = "Static public IP address"
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_name" {
  description = "Public IP resource name"
  value       = azurerm_public_ip.pip.name
}

output "public_ip_fqdn" {
  description = "Public IP FQDN (if domain_name_label set)"
  value       = azurerm_public_ip.pip.fqdn
}

output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_id" {
  description = "Virtual machine ID"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  description = "VM private IP address"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "ssh_public_key" {
  description = "SSH public key (generated or provided)"
  value       = local.ssh_public_key
}

output "ssh_private_key" {
  description = "SSH private key (only if generated)"
  value       = local.ssh_private_key
  sensitive   = true
}