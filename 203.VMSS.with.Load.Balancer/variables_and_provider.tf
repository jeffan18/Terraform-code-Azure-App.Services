variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}

variable "location" {
  description = "The location for VMSS"
  default = "East US 2"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  default = {
    environment = "staging"
  }
}

variable "resource_group_name" {
 description = "The name of the resource group"
 default     = "RG02-Staging-eastus2-20200129"
}

variable "vnet_name" {
 description = "The name of the virtual network"
 default     = "VNet01-in-RG02-Staging-eastus2-20200129"
}

variable "vmss_subnet1_name" {
 description = "The name of the subnet for Jump box"
 default     = "Subnet01-in-VNet01-Staging-eastus2-20200129"
}

variable "vmss_subnet2_name" {
 description = "The name of the subnet for VMSS"
 default     = "Subnet02-in-VNet01-Staging-eastus2-20200129"
}

variable "public_ip_name" {
 description = "The Public IP name for VMSS LB front end"
 default     = "PublicIP-VMSS-Staging-eastus2-20200129"
}

variable "public_ip_for_jumpbox_name" {
 description = "The Public IP name for Jumpbox"
 default     = "PublicIP-Jumpbox-Staging-eastus2-20200129"
}

variable "vmss_lb_name" {
  description = "The Load Balancer name in front of the VMSS"
  default     = "LB-VMSS-Staging-eastus2-20200129"
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "vm_scaleset_name" {
  description = "The name of the VM Scale Set"
  default     = "VMSS-Staging-eastus2-20200129"
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "elecview"
}

variable "admin_password" {
  description = "Default password for admin account"
  default = "Miss9521"
}


provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
}

