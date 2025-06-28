resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_linux_virtual_machine" "minikube_vm" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-vm-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.minikube_nic[0].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  custom_data = var.install_minikube ? base64encode(templatefile(var.minikube_script_path, {
    admin_username = var.admin_username
  })) : null

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

  tags = var.tags
}

# Supporting resources (conditional based on create_vm)
resource "azurerm_network_interface" "minikube_nic" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id != "" ? var.subnet_id : azurerm_subnet.minikube_subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.minikube_pip[0].id
  }

  depends_on = [
    azurerm_subnet.minikube_subnet,
    azurerm_public_ip.minikube_pip,
    azurerm_network_security_group.minikube_nsg
  ]
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Only create these if no existing subnet provided
resource "azurerm_virtual_network" "minikube_vnet" {
  count               = var.create_vm && var.subnet_id == "" ? 1 : 0
  name                = "minikube-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "minikube_subnet" {
  count                = var.create_vm && var.subnet_id == "" ? 1 : 0
  name                 = "minikube-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.minikube_vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "minikube_pip" {
  count               = var.create_vm ? 1 : 0
  name                = "minikube-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"  # More secure than Basic
}

resource "azurerm_network_security_group" "minikube_nsg" {
  count               = var.create_nsg ? 1 : 0
  name                = "minikube-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_allowed_ip_cidr # e.g. "YOUR.IP.ADDR.0/32"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Dev"
    Purpose     = "Allow SSH to VM"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.minikube_nic.id
  network_security_group_id = azurerm_network_security_group.minikube_nsg.id

  depends_on = [
    azurerm_network_security_group.minikube_nsg,
    azurerm_network_interface.minikube_nic
  ]
}