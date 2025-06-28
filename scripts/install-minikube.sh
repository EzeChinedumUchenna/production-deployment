#!/bin/bash

# Secure installation of Minikube on Azure VM
set -euo pipefail

ADMIN_USER=${admin_username}

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    conntrack

# Install Docker (for Minikube driver)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $ADMIN_USER

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Configure Minikube to use Docker driver
sudo -u $ADMIN_USER minikube config set driver docker

# Start Minikube (as regular user)
sudo -u $ADMIN_USER minikube start --force

# Enable ingress addon
sudo -u $ADMIN_USER minikube addons enable ingress

# Verify installation
sudo -u $ADMIN_USER minikube status
sudo -u $ADMIN_USER kubectl get pods -A