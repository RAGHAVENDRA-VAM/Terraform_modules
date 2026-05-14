# =============================================================================
# terraform.tfvars — Azure VM Module
# =============================================================================

vm_name             = "dev-web-vm"
location            = "East US"
resource_group_name = "rg-dev"
vm_size             = "Standard_B2s"
os_type             = "Linux"
admin_username      = "azureuser"
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host"

subnet_id        = "/subscriptions/<sub-id>/resourceGroups/rg-dev/providers/Microsoft.Network/virtualNetworks/dev-vnet/subnets/private"
create_public_ip = false

os_disk_type    = "Premium_LRS"
os_disk_size_gb = 30

image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-jammy"
image_sku       = "22_04-lts-gen2"
image_version   = "latest"

identity_type = "SystemAssigned"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
