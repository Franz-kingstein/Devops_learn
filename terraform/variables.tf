# Root module variables for DevOps IA-3 Azure deployment
# All resources will be tagged with these common tags

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
  validation {
    condition     = contains(["East US", "West US 2", "Central US", "West Europe", "North Europe", "Central India"], var.location)
    error_message = "Location must be a supported Azure region."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "devops-ia3"
  validation {
    condition     = length(var.project_name) <= 20
    error_message = "Project name must be 20 characters or less."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Owner tag for resources (email or name)"
  type        = string
  default     = "student@example.com"
}

variable "admin_username" {
  description = "Admin username for the Linux VM (no root, no admin)"
  type        = string
  default     = "azureuser"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.admin_username))
    error_message = "Username must start with letter, 3-31 chars, lowercase alphanumeric and hyphens only."
  }
}

variable "vm_size" {
  description = "Azure VM size (SKU) for the compute instance"
  type        = string
  default     = "Standard_B2s"
  validation {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_B4ms", "Standard_D2s_v5", "Standard_D4s_v5", "Standard_B2ats_v2"], var.vm_size)
    error_message = "VM size must be one of the allowed sizes."
  }
}

variable "zone" {
  description = "Availability zone for VM and Public IP"
  type        = string
  default     = "1"
  validation {
    condition     = contains(["1", "2", "3"], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (e.g., ~/.ssh/id_rsa.pub). If not set, a new key pair will be generated."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access (port 22). Restrict in production!"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for cidr in var.allowed_ssh_cidrs : can(regex("^\\d{1,3}(\\.\\d{1,3}){3}/\\d{1,2}$", cidr))])
    error_message = "Each CIDR must be in valid format (e.g., 10.0.0.0/8)."
  }
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP access (port 80)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_version" {
  description = "Application version to deploy (passed to cloud-init)"
  type        = string
  default     = "1.0.0"
}

variable "github_repo_url" {
  description = "GitHub repository URL for the application code"
  type        = string
  default     = "https://github.com/your-org/devops-ia3-azure-cicd.git"
}

# Common tags applied to all resources
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}