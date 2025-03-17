resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

module "aks" {
  source              = "../../modules/aks"
  resource_group_name = var.resource_group_name
  cluster_name        = var.cluster_name
  location            = var.location
  role_definition_name = var.role_definition_name
  dns_prefix = var.dns_prefix
  client_id = "${local.client_id}"
  tags = var.tags

  depends_on = [azurerm_resource_group.aks_rg]
}

locals {
  client_id = "19f13611-1c52-4e56-9ad7-424d00209dde"
}