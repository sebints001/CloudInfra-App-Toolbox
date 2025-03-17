resource "azurerm_role_assignment" "aks_rbac" {
  principal_id         = var.client_id # Azure AD Application or Service Principal
  role_definition_name = var.role_definition_name
  scope                = azurerm_kubernetes_cluster.aks.id
}
