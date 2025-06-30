# FastAPI Production Deployment Runbook: FastAPI + Kubernetes + Observability Stack
This project automate the deployment of the FastAPI application into a Minikube-based Kubernetes cluster running on an Azure VM. It integrates:
   - Secure app deployment with GitHub Actions
   - Pod security policies
   - Monitoring and observability with Prometheus, Grafana, and Loki
   - External traffic routing via NodePort and host-level NGINX reverse proxy

## Kubernetes Infrastructure Setup
### Minikube Installation (on Azure VM)
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube start --driver=none
```
### Required Add-ons
```bash
minikube addons enable ingress
minikube addons enable metrics-server
```

## Application Deployment (CI/CD)
### GitHub Actions Workflow
Triggered on changes to /k8s or /security. Key pipeline steps:
- Docker builds tagged with run number and latest
- Image pushed to DockerHub
- SSH into VM and deploy manifests with:
  
```bash
kubectl apply -f ...
kubectl rollout status deployment/fastapi-app
```
```
FastAPI Deployment Files
configmap.yml
hpa.yml
deployment.yml
service.yml
```
All deployed to the prod namespace on the cluster.

## Pod Security Enforcement
### PSA Labels on Namespace -Ensures runAsNonRoot: true and Policy enforced in prod namespace via ClusterPolicy
kubectl label --overwrite ns prod \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest

## Monitoring Stack (Monitoring.sh Script)

**Component|	Method	            | Namespace**
Prometheus |	prometheus-community |	monitoring
Grafana	  |   grafana/grafana      | 	monitoring
Loki	     | grafana/loki-stack	   | monitoring
