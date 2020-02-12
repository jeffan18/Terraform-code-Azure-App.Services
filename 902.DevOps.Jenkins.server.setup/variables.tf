provider "azurerm" {
  subscription_id        = "${var.subscription_id}"
  client_id              = "${var.client_id}"
  client_secret          = "${var.client_secret}"
  tenant_id              = "${var.tenant_id}"
}

# Azure Credentials

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Variables

variable "location" { default  = "eastus" }
variable "resource_group_name" { default = "jenkins" }
variable "vnet_cidr" { default = "192.168.0.0/16" }
variable "subnet_cidr" { default = "192.168.1.0/24" }
variable "vm_username" {}
variable "vm_password" {}
variable "vm_size" { default = "Standard_DS1_v2" }

variable "network_name" { default = "jenkins-virtual-network" }
variable "subnet_name" { default = "Jenkins-Subnet" }
variable "security_group_name" { default = "Jenkins-SecurityGroup"}
variable "vm_name" { default = "Jenkins_VM" }
variable "os_name" { default = "Ubuntu_Jenkins" }
