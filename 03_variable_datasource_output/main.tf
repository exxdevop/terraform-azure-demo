# usage example: terraform apply -var "my_rg=simplevm"

variable "my_rg" {
  type    = "string"
  default = "resourcegroup_x"
}

data "azurerm_virtual_network" "my_network" {
  name                = "simplevmNetwork"
  resource_group_name = "${var.my_rg}"
}

output "my_network_id" {
  value = "${data.azurerm_virtual_network.my_network.id}"
}
