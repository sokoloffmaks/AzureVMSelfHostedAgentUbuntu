variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location for the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP (Static or Dynamic)"
  type        = string
}

variable "public_ip_sku" {
  description = "The SKU for the public IP (Basic or Standard)"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "vm_admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "ssh_public_key_path" {
  description = "The file path of the SSH public key"
  type        = string
}
