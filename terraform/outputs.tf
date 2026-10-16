# Root module outputs
# Exposes key information from network and compute modules

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = module.network.resource_group_name
}

output "resource_group_id" {
  description = "ID of the Azure Resource Group"
  value       = module.network.resource_group_id
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = module.network.vnet_name
}

output "virtual_network_id" {
  description = "ID of the Virtual Network"
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "ID of the Subnet"
  value       = module.network.subnet_id
}

output "subnet_name" {
  description = "Name of the Subnet"
  value       = module.network.subnet_name
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = module.network.nsg_id
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = module.network.nsg_name
}

output "public_ip_address" {
  description = "Static public IP address of the VM"
  value       = module.compute.public_ip_address
}

output "public_ip_name" {
  description = "Name of the Public IP resource"
  value       = module.compute.public_ip_name
}

output "public_ip_fqdn" {
  description = "Fully qualified domain name of the public IP (if DNS label set)"
  value       = module.compute.public_ip_fqdn
}

output "vm_name" {
  description = "Name of the Virtual Machine"
  value       = module.compute.vm_name
}

output "vm_id" {
  description = "ID of the Virtual Machine"
  value       = module.compute.vm_id
}

output "vm_private_ip" {
  description = "Private IP address of the VM (NIC)"
  value       = module.compute.vm_private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i <path-to-private-key> ${var.admin_username}@${module.compute.public_ip_address}"
}

output "app_url" {
  description = "Application URL (HTTP on port 80 via nginx)"
  value       = "http://${module.compute.public_ip_address}"
}

output "app_health_url" {
  description = "Application health check URL"
  value       = "http://${module.compute.public_ip_address}/health"
}

output "ssh_private_key" {
  description = "Generated SSH private key (sensitive - handle with care!)"
  value       = module.compute.ssh_private_key
  sensitive   = true
}