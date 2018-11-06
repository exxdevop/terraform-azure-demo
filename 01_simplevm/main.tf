resource "azurerm_resource_group" "simplevm" {
  name     = "simplevm"
  location = "westeurope"
}

resource "azurerm_virtual_network" "simplevm" {
  name                = "simplevmNetwork"
  address_space       = ["10.66.0.0/16"]
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.simplevm.name}"
}

resource "azurerm_subnet" "simplevm" {
  name                 = "simplevmSubnet"
  resource_group_name  = "${azurerm_resource_group.simplevm.name}"
  virtual_network_name = "${azurerm_virtual_network.simplevm.name}"
  address_prefix       = "10.66.0.0/24"
}

resource "azurerm_public_ip" "simplevm" {
  name                         = "simplevmPublicIp"
  location                     = "westeurope"
  resource_group_name          = "${azurerm_resource_group.simplevm.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "simplevm"
  }
}

resource "azurerm_network_interface" "simplevm" {
  name                = "simplevmNic"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.simplevm.name}"

  ip_configuration {
    name                          = "simplevmIpConfiguration"
    subnet_id                     = "${azurerm_subnet.simplevm.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.simplevm.id}"
  }
}

resource "azurerm_virtual_machine" "simplevm" {
  name                  = "simplevmVm"
  location              = "westeurope"
  resource_group_name   = "${azurerm_resource_group.simplevm.name}"
  network_interface_ids = ["${azurerm_network_interface.simplevm.id}"]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "simplevmVmDisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "simplevmVm"
    admin_username = "vmadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "simplevm"
  }
}
