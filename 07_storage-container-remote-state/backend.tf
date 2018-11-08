# Quelle: http://www.mikaelkrief.com/terraform-remote-backend-azure/

terraform {
  backend "azurerm" {
    storage_account_name     = "exxtfremotestate"
    resource_group_name      = "rg-demo"
    container_name           = "demo"
    key                      = "terraform.tfstate"
    access_key               = "nja4jOSX520e5YpX9VoHVEH03/e1sInme1PqQTYeiPj+QVUvZKCg0k1mdjv7HVON9Rx6XuhdXZa8VZJIAXsPWA=="
  }
}

# ========================================================================


data "azurerm_storage_account" "rg-demo-tf-state" {
  name                = "exxtfremotestate"
  resource_group_name = "${azurerm_resource_group.rg-demo.name}"
  depends_on          = ["azurerm_storage_account.rg-demo-tfstate"]
}

output "storage_account_primary_access_key" {
  value = "${data.azurerm_storage_account.rg-demo-tf-state.primary_access_key}"
}

resource "azurerm_resource_group" "rg-demo" {
  name     = "rg-demo"
  location = "westeurope"
}

resource "azurerm_storage_account" "rg-demo-tfstate" {
  name                     = "exxtfremotestate"
  location                 = "westeurope"
  resource_group_name      = "${azurerm_resource_group.rg-demo.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "rg-demo-tfstate-demo" {
  name                  = "demo"
  resource_group_name   = "${azurerm_resource_group.rg-demo.name}"
  storage_account_name  = "${azurerm_storage_account.rg-demo-tfstate.name}"
  container_access_type = "private"
}