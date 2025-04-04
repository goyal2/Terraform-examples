output "vm_public_ip" {
  description = "Public Ip of virtual machine"
  value = azurerm_public_ip.public_ip.ip_address
}
