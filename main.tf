provider "azurerm" {
  features {}
  subscription_id = "0e867537-cf4c-47c3-9de2-b5646da86f8e"
}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East Us"
}
# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnetjecrc"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnetjerc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku = "Standard"
}
# Create Network Security Group and rule
# resource "azurerm_network_security_group" "myterraformnsg" {
#   name                = "myNetworkSecurityGroup"
#  location            = "Central India"
#  resource_group_name = azurerm_resource_group.myterraformgroup.name

#  security_rule {
#    name                       = "SSH"
#    priority                   = 1001
#    direction                  = "Inbound"
#   access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_ranges    = ["22", "80", "443", "32323"]
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#}
# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "myNICjecrc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
# Connect the security group to the network interface
#resource "azurerm_network_interface_security_group_association" "example" {
#  network_interface_id      = azurerm_network_interface.myterraformnic.id
#  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
#}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "myUbuntuVM"
  location              = "Cental India"
  resource_group_name   = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B2s"
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:\\Users\\91882\\.ssh\\id_rsa.pub")  # Ensure you have an SSH key generated
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myUbuntuvm"
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = file("C:\\yUsers\\91882\\.ssh\\id_rsa")
    host        = azurerm_public_ip.public_ip.ip_address
  }
}
