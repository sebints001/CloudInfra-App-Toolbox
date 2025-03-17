resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  min_tls_version           = "TLS1_2"
}

resource "azurerm_storage_blob" "encrypted_blob" {
  storage_container_name = var.storage_container_name
  name                   = "encrypted-data"
  storage_account_name   = azurerm_storage_account.storage.name

  source                 = "path/to/your/data"
  type                   = "Block"
  content_md5            = filebase64sha256("path/to/your/data")
}
