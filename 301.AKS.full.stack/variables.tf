/* Azure Credentials for Terraform */
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

/* Project, environment, location */
variable "environment" {
 default = "dev"
}

variable "dns_prefix" {
 default = "fan"
}

variable "project" {
 default = "aksfull20200212"
}

variable "location" {
 default = "East US"
}

locals {
 kubernetes_cluster_name = "${var.dns_prefix}-${var.project}-${var.environment}-01"
}

/* Resources */
variable "resource_group_name" {
 description = "resource group of the resources."
 default = "RG-Fan-eastus-20200212"
}

variable "vnet_name" {
 description = "Virtual network name"
 default     = "VNet-Fan-eastus-20200212"
}

variable "vnet_address_space" {
  type        = "string"
  description = "Address space for the vnet"
  default     = "10.0.0.0/8"
}

variable "subnet_aks" {
  type        = "string"
  description = "Address space for the AKS subnet"
  default     = "10.1.0.0/16"
}

variable "subnet_gateway_ingress" {
  type        = "string"
  description = "Address space for the gateway subnet"
  default     = "10.2.0.0/24"
}

variable "subnet_gateway" {
  type        = "string"
  description = "Address space for the gateway subnet"
  default     = "10.2.1.0/24"
}

variable "vip_load_balancer_ingress" {
  type        = "string"
  description = "Address for the ingress controller load balancer"
  default     = "10.2.0.10"
}

variable "node_os" {
  type        = "string"
  description = "Windows or Linux"
  default     = "Linux"
}

variable "node_count" {
  type        = "string"
  description = "The number of K8S nodes to provision."
  default     = 2
}

variable "node_type" {
  type        = "string"
  description = "The size of each node."
  default     = "Standard_D1_v2"
}

