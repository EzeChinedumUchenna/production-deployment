terraform {
  backend "azurerm" {
    resource_group_name  = "my-tfstate-rg"
    storage_account_name = "mytfstatestorageacct"
    container_name       = "tfstate"
    key                  = "minikube-vm/terraform.tfstate"
  }
}
