module "minikube_vm" {
  source = "./modules/minikube-vm"
  
  # Toggle Minikube VM creation
  create_vm = false  # Set to false to skip VM creation
  create_nsg = true # Set to false to skip nsg creation
  install_minikube   = true   # Only install Minikube when true ..
  
  # Required parameters
  resource_group_name = "Rayda"
  # location           = "eastus"
  
  # Optional parameters with defaults
  vm_size          = "Standard_B2s"
  minikube_script_path = "../scripts/install-minikube.sh"
  admin_username   = "minikubeadmin"
  ssh_allowed_ip_cidr = "0.0.0.0/0"
  ssh_public_key = var.ssh_public_key
}