variable "create_vm" {
  description = "Whether to create the VM and its associated resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "Size of the Azure Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

variable "subnet_id" {
  description = "ID of an existing subnet to use, leave blank to create new"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of resource tags to apply"
  type        = map(string)
  default     = {}
}
