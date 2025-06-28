module "minikube_vm" {
  source = "./modules/minikube-vm"
  
  # Toggle Minikube VM creation
  create_vm = true  # Set to false to skip creation
  install_minikube   = false   # Only install Minikube when true
  
  # Required parameters
  resource_group_name = "my-resource-group"
  location           = "eastus"
  
  # Optional parameters with defaults
  vm_size          = "Standard_B2s"
  admin_username   = "minikubeadmin"
  ssh_public_key   = file("~/.ssh/id_rsa.pub")
  tags = {
    Environment = "Dev"
    Purpose     = "K8s Testing"
  }
}