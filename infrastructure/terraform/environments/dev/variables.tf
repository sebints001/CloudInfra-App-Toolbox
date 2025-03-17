variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags for dev resources"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "terraform-aks"
  }
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster"
  type        = string
  default     = "dev-aks-cluster"
}

variable "cluster_name" {
  description = "Name for the AKS cluster"
  type        = string
  default     = "dev-aks-rg"
}

variable "state_resource_group" {
  description = "Resource group where the Terraform state is stored"
  type        = string
}

variable "state_storage_account" {
  description = "Storage account name for the Terraform state"
  type        = string
}

variable "state_container_name" {
  description = "Container name within the storage account for the state file"
  type        = string
}

variable "state_file_key" {
  description = "Key (file name) for storing the Terraform state"
  type        = string
}

variable "role_definition_name" {
  description = "Azure Kubernetes Service Cluster User Role"
  type        = string
}

variable "dns_prefix" {
  description = "Azure Kubernetes Service Cluster DNS Prefix"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID where resources will be deployed"
  type        = string
}

variable "client_id" {
  description = "Azure client id"
  type        = string
}

variable "client_secret" {
  description = "Azure client secret"
  type        = string
}


variable "tenant_id" {
  description = "Azure tenant id"
  type        = string
}
