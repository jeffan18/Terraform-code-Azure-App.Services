variable "client_id" {}
variable "client_secret" {}

variable resource_group_name {
  default = "RG02-eastus-20200112"
}

variable location {
  default = "East US"
}

variable log_analytics_workspace_name {
  default = "LogAnalyticsWS-eastus-20200112"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}
variable "workernodes_count" {
  default = 2
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "fanakstest"
}

variable cluster_name {
    default = "AKS01-useast-20200123"
}

