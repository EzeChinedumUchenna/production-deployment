# Production-Ready FastAPI Service Deployment

This project demonstrates how to deploy a FastAPI service in a production-ready Kubernetes environment using minikube. It includes security hardening, monitoring, CI/CD, and operational best practices.

---
## Prerequisites

- Azure Subscription
- SSH key pair (`id_rsa`, `id_rsa.pub`)
- minikube v1.30+
- kubectl v1.28+
- Docker 20.10+
- Python 3.9+
- Helm (for monitoring setup)
---
## Features

- Deployment of the infrastructure and minikube using Terraform Modular, reusable Terraform layout and best practices
- Multi-stage Docker build with security scanning
- Secure configuration using GitHub Secrets, SSH key injected securely into the server
- Network Security Group (NSG) with controlled SSH ingress and other Access
- Set up all k8s service at a run
- Security of Pod Access using - Network policy, service account, Network policy and Pod security policy
- Monitoring stack with Prometheus/Grafana
- Logging using Loki and Grafana for visualization
- GitHub Actions CI/CD pipeline
- Security hardening:
    - Non-root container user
    - Pod security policies
    - Secrets management
- Kubernetes deployment with:
    - Resource limits and requests
    - Liveness/readiness probes
    - Horizontal Pod Autoscaler
    - Network policies

---
## Quick Start

1. **Execute the terraform-deploy.yml using the terraform-deploy.yml pipeline**
   This pipeline install Azure VM using terraform and install minikube( using "install-minikube.sh" script). See below
 
2. **Run Configuration Scripts using the execute-script pipeline:**
   The following scripts (configure-metricserver.sh, configure-nginx.sh, install-gateekeeper.sh, monitoring.sh, install-nginx.sh)
   - configures the metric server need for the HPA to get the CPU metric.
   - Install Nginx on the server and configure nginx for proper routing of the external traffic into the Minikube VM from the Azure VM(Host VM)
   - Install gatekeep for Pod security policy since PSP has been deprecated
   - Install monitoring using helm
     
 3. **Deploy all the kubernetes service using the execute-script.yml pipeline**
    By running this pipeline you would be deploying all service under k8s and security folder at a go . 



## Project Structure

/rayda-assessment
├── Dockerfile            # Multi-stage, security-hardened
├── k8s/                 # Kubernetes manifests
├── .github/workflows/   # CI/CD pipeline
├── monitoring/          # Observability
├── scripts/            # Automation
├── security/           # Security policies
├── README.md          # Deployment guide
└── RUNBOOK.md        # Operations manual

---

