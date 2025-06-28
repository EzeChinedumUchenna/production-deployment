# ☁️ Minikube VM Provisioning with Terraform on Azure

This project automates the provisioning of an Azure Linux VM and installs Minikube using Terraform. It leverages GitHub Actions to deploy infrastructure, manage state securely, and enforce best practices.

---

## 📦 Features

- 🚀 Create Linux VM on Azure with SSH access
- 🔐 Secure configuration using GitHub Secrets
- 🛡️ Network Security Group (NSG) with controlled SSH ingress
- 🧰 Installs Minikube using `cloud-init` and shell script injection
- 🔄 GitHub Actions CI/CD pipeline with state locking, formatting, and deployment
- 📄 Modular, reusable Terraform layout

---

## 🗂️ Project Structure

. ├── terraform/ │ ├── main.tf # Root Terraform config │ ├── variables.tf # Input variables │ ├── terraform.tfvars # Values for variables │ └── modules/ │ └── minikube-vm/ │ └── main.tf # Module logic ├── scripts/ │ └── install-minikube.sh # Cloud-init script to install Minikube ├── .github/ │ └── workflows/ │ └── terraform.yml # GitHub Actions deployment workflow ├── runbook.md └── README.md



---

## 🔧 Prerequisites

- Azure Subscription
- SSH key pair (`id_rsa`, `id_rsa.pub`)
- GitHub Secrets:
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
  - `AZURE_PUBLIC_KEY`

---

## 🚀 Usage

### 1. Clone this repo

```bash
git clone https://github.com/your-org/minikube-vm-terraform.git
cd minikube-vm-terraform

Customizing
You can adjust:

VM size (vm_size)

Resource group/location

NSG CIDR restriction via ssh_allowed_ip_cidr

Minikube install toggle via install_minikube



![Terraform Version](https://img.shields.io/badge/Terraform-v1.7.5-blue?logo=terraform)
![Azure](https://img.shields.io/badge/Platform-Azure-blue?logo=microsoftazure)
![CI](https://github.com/<your-username>/<repo-name>/actions/workflows/terraform.yml/badge.svg)

Security Extras
✅ Secrets never hardcoded (uses GitHub Secrets only)

✅ SSH key injected securely

✅ NSG restricts access to known CIDR blocks (you can tighten this down anytime)