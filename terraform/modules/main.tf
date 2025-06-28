resource "azurerm_linux_virtual_machine" "minikube_vm" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-vm-${random_id.suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.minikube_nic[0].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/install-minikube.sh", {
    admin_username = var.admin_username
  }))

  tags = var.tags
}

# Supporting resources (conditional based on create_vm)
resource "azurerm_network_interface" "minikube_nic" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id != "" ? var.subnet_id : azurerm_subnet.minikube_subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.minikube_pip[0].id
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Only create these if no existing subnet provided
resource "azurerm_virtual_network" "minikube_vnet" {
  count               = var.create_vm && var.subnet_id == "" ? 1 : 0
  name                = "minikube-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "minikube_subnet" {
  count                = var.create_vm && var.subnet_id == "" ? 1 : 0
  name                 = "minikube-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.minikube_vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "minikube_pip" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"  # More secure than Basic
}