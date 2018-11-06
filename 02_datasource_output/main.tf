data "azurerm_virtual_network" "my_network" {
  name                = "simplevmNetwork"
  resource_group_name = "simplevm"
}

output "my_network_id" {
  value = "${data.azurerm_virtual_network.my_network.id}"
}
