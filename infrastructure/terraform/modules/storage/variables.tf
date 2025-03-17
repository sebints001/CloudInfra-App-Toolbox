variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_container_name" {
  description = "Name of the storage container"
  type        = string
}
variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the network"
  type        = string
}   