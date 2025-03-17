variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure location for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for nodes in the default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
variable "client_id" {
  description = "Azure AD Application ID or Service Principal ID for RBAC assignment to the AKS cluster"
  type        = string
}

variable "role_definition_name" {
  description = "Azure Kubernetes Service Cluster role definition"
  type        = string
}

variable "dns_prefix" {
  description = "Azure Kubernetes Service Cluster DNS Prefix"
  type        = string
  default     = "mykubernetestest00111"
}