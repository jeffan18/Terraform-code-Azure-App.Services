/* Azure Credentials for Terraform */
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}


/* Locals – for the main services defines */
locals {
app_service_name = "${var.dns_prefix}-${var.project}-${substr(var.environment, 0, 3)}-app"
app_service_plan_name = "${var.project}-${substr(var.environment, 0, 3)}-plan"
}


/* Project, environment, location */
variable "environment" {
default = "development"
}


variable "dns_prefix" {
default = "fan"
}


variable "project" {
default = "linuxdocker"
}


variable "location" {
default = "East US"
}


/* Resources */
variable "resource_group_name" {
description = "resource group of the resources."
default = "RG-Fan-eastus-20200206"
}


variable "plan_tier" {

type = "string"
description = "The tier of app service plan to create"
default = "Standard"
}


variable "plan_sku" {

type = "string"
description = "The sku of app service plan to create"
default = "S1"
}
