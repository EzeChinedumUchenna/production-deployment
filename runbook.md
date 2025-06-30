# FastAPI Production Deployment Runbook: FastAPI + Kubernetes + Observability Stack
This project automate the deployment of the FastAPI application into a Minikube-based Kubernetes cluster running on an Azure VM. It integrates:
   - Secure app deployment with GitHub Actions
   - Pod security policies
   - Monitoring and observability with Prometheus, Grafana, and Loki
   - External traffic routing via NodePort and host-level NGINX reverse proxy

```markdown
# 🛠️ Minikube VM Terraform Runbook

This runbook captures the operational steps, troubleshooting processes, and team decisions that support the infrastructure in this repo.

---

## 📋 Overview

This Terraform workflow deploys a single Linux VM on Azure, installs Minikube via cloud-init using a shell script, and configures network and security for SSH-based access.

---

## 🔑 Authentication

- Uses service principal credentials (ARM_* variables) stored in GitHub Secrets.
- Ensure your service principal has `Contributor` access to the resource group.

---

## 🧠 Deployment Flow

### GitHub Actions

1. `push` or `pull_request` to `main` with changes in `terraform/` triggers workflow
2. Workflow:
   - Initializes Terraform in `./terraform`
   - Runs `terraform fmt`, `validate`
   - Optionally runs `terraform plan`
   - Applies changes via `terraform apply -auto-approve`

---

## 📦 VM Configuration

- **VM Size:** `Standard_B2s` by default
- **Username:** `minikubeadmin`
- **SSH Access:** Injected via `TF_VAR_ssh_public_key`
- **Minikube Installation:**
  - Triggered by `install_minikube = true`
  - Uses `templatefile()` to inject `scripts/install-minikube.sh` as cloud-init `custom_data`
- **NSG:** Allows port 22 inbound from `ssh_allowed_ip_cidr`

---

## 🔒 State Locking

- State stored remotely in Azure Blob Storage.
- Concurrency protected by Terraform's internal locking.
- If stuck, unlock manually:

```bash
terraform force-unlock -force <LOCK_ID>


Error	Cause	Fix
state blob is already locked	Stuck lock	Run force-unlock -force
Missing resource instance key	Using count without index	Use resource[count.index]
terraform plan triggers destroy	Auto-generated resource names change	Set explicit os_disk.name
SSH: Host key has changed	VM recreated but IP reused	Run ssh-keygen -R <ip>

Best Practices
Use TF_VAR_ environment variables instead of writing to terraform.tfvars

Use count guards like create_vm ? 1 : 0

Pin all versions (e.g., terraform_version: 1.7.5)

Use -no-color and tee apply.log in CI for clean logging
