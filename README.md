# Production-Ready FastAPI Service Deployment on Kubernetes

This project demonstrates how to deploy a FastAPI service in a **production-ready Kubernetes environment** using Minikube on an Azure VM. It incorporates best practices in **security hardening**, **observability**, **CI/CD**, and **infrastructure automation**.

---

## Prerequisites

Ensure the following are installed or configured:

- ✅ Azure Subscription
- ✅ SSH key pair (`id_rsa`, `id_rsa.pub`)
- ✅ [Minikube](https://minikube.sigs.k8s.io/docs/)
- ✅ [Terraform](https://www.terraform.io/)
- ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/)
- ✅ [Helm](https://helm.sh/)

---

## ✅ Key Features

- **Infrastructure-as-Code**:
  - Azure VM and Minikube provisioned via modular, reusable Terraform modules
  - NSG (Network Security Group) with restricted SSH and port access

- **Secure Docker Image Build**:
  - Multi-stage build
  - Security-hardened base image
  - Built and pushed using GitHub Actions

- **Kubernetes Deployment**:
  - Resource limits and requests
  - Liveness and readiness probes
  - Horizontal Pod Autoscaler (HPA)
  - Pod Security Admission (via OPA Gatekeeper)
  - Network Policies
  - Service Account scoping

- **Security Hardening**:
  - Runs as non-root user
  - Privilege escalation disabled
  - PSP migration using OPA Gatekeeper
  - Secrets and config management via Kubernetes Secrets and ConfigMaps

- **CI/CD Pipeline (GitHub Actions)**:
  - Docker image build and push
  - SCP deployment to remote VM
  - Kubernetes manifests applied remotely

- **Monitoring and Logging**:
  - Prometheus & Grafana for metrics
  - Loki for centralized logging
  - Dashboards and alerts included

---

## ⚡ Quick Start Guide

### 1. 🚀 Deploy Infrastructure (Azure VM + Minikube)
Trigger the `terraform-deploy.yml` GitHub Actions pipeline. This will:

- Provision an Azure VM using Terraform
- SSH into the VM and run `install-minikube.sh` to install Minikube

### 2. 🔧 Configure Environment (Metric Server, NGINX, Gatekeeper, Monitoring)
Trigger the `execute-script.yml` pipeline to run the following scripts:

- `configure-metricserver.sh`: Enables metrics for HPA
- `install-nginx.sh`: Installs and configures NGINX for ingress from Azure VM → Minikube
- `install-gatekeeper.sh`: Deploys OPA Gatekeeper for enforcing pod security
- `monitoring.sh`: Installs Prometheus, Grafana, and Loki using Helm

### 3. 📦 Deploy FastAPI and Kubernetes Resources
Still in `execute-script.yml`, the pipeline will:

- Apply all Kubernetes manifests under `k8s/` and `security/`
- Ensure services, deployments, RBAC, and security controls are in place

---

## 🧭 Project Structure

```text
rayda-assessment/
├── Dockerfile             # Multi-stage, security-hardened FastAPI image
├── k8s/                   # Kubernetes manifests (Deployments, Services, Ingress, etc.)
├── .github/workflows/     # GitHub Actions CI/CD workflows
├── monitoring/            # Helm charts for Prometheus, Grafana, Loki
├── scripts/               # Automation scripts (Terraform, Minikube, Monitoring)
├── security/              # RBAC, Gatekeeper templates, NetworkPolicies
├── README.md              # This file – project overview and instructions
└── RUNBOOK.md             # Operational handbook for production troubleshooting
