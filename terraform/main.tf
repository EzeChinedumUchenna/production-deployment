module "minikube_vm" {
  source = "./modules/minikube-vm"
  
  # Toggle Minikube VM creation
  create_vm = true  # Set to false to skip creation
  install_minikube   = true   # Only install Minikube when true
  
  # Required parameters
  resource_group_name = "Rayda"
  # location           = "eastus"
  
  # Optional parameters with defaults
  vm_size          = "Standard_B2s"
  admin_username   = "minikubeadmin"
  ssh_public_key = var.ssh_public_key
  tags = {
    Environment = "Dev"
    Purpose     = "K8s Testing"
  }
}