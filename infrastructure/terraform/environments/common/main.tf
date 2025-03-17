resource "azurerm_resource_group" "common" {
  name     = "common-resources-rg"
  location = var.location
  tags     = var.tags
}
