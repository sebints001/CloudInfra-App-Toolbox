variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {
    environment = "common"
    project     = "terraform-aks"
  }
}
