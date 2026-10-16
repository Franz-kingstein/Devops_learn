# Compute Module Variables
# Input variables for compute resources

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to attach NIC to"
  type        = string
}

variable "nsg_id" {
  description = "ID of the network security group"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "nic_name" {
  description = "Name of the network interface"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP resource"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "vm_size" {
  description = "VM size (SKU)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key (optional - if empty, a new key pair is generated)"
  type        = string
  default     = ""
}

variable "app_version" {
  description = "Application version to deploy"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository URL for the application"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "zone" {
  description = "Availability zone for VM and Public IP (1, 2, or 3)"
  type        = string
  default     = "1"
  validation {
    condition     = contains(["1", "2", "3"], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}