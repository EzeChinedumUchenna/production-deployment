# FastAPI Production Deployment Runbook: FastAPI + Kubernetes + Observability Stack
This project automate the deployment of the FastAPI application into a Minikube-based Kubernetes cluster running on an Azure VM. It integrates:
   - Provision Minikube (using Terraform) VM with GitHub Actions
   - App deployment with GitHub Actions
   - Pod security policies
   - Monitoring and observability with Prometheus, Grafana, and Loki
   - External traffic routing via NodePort and host-level NGINX reverse proxy

## 1. Kubernetes Infrastructure Setup
### Minikube Installation (on Azure VM)
We automated the process but you can configure Minikube using the below
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

## 2. Application Deployment (CI/CD)
### GitHub Actions Workflow
Triggered on changes to /k8s or /security and /monitoring. Key pipeline steps:
- Docker builds tagged with run number and latest
- Image pushed to DockerHub
- SSH into VM and deploy manifests with:
  
```bash
kubectl apply -f ...
kubectl rollout status deployment/fastapi-app
```

### FastAPI Deployment Files
```
configmap.yml
hpa.yml
deployment.yml
service.yml
```
All deployed to the prod namespace on the cluster.

## 3. Pod Security Enforcement
### PSA Labels on Namespace -Ensures runAsNonRoot: true and Policy enforced in prod namespace via ClusterPolicy
kubectl label --overwrite ns prod \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest

## 4. Monitoring Stack (Monitoring.sh Script or apply k8s yamls in monitoring/)

| Component  | Method                   | Namespace  |
|------------|--------------------------|------------|
| Prometheus | prometheus-community     | monitoring |
| Grafana    | grafana/grafana          | monitoring |
| Loki       | grafana/loki-stack       | monitoring |

### To Apply
```bash
kubectl apply -f monitoring/prometheus/
kubectl apply -f monitoring/grafana/
```
**Note:** For Now we are only monitoring the availabilty of the service uptime (i.e., whether an HTTP /health endpoint is reachable), not full cluster-level metrics like CPU, memory, disk usage, pod counts, etc. so no Node Exporter is scrapping the OS-level metrics
### Access Services in Minikube
```bash
minikube service prometheus-service
minikube service grafana-service
```

## 5. Logging Stack (monitoring/loki.yml)
We centralized logging using Loki and integrate it with your existing Grafana setup deployed via YAML on Minikube. Here is what we did:
- Deployed Loki using a YAML manifest.
- Deployed Promtail (log collector for Loki).
- Configured Loki as a datasource in Grafana using a ConfigMap.

### To apply the setup
```bash
kubectl apply -f monitoring/loki/
kubectl apply -f monitoring/promtail/
kubectl apply -f monitoring/grafana/
```
### Verify
- Run minikube ```service grafana-service``` to get Grafana URL.
- Login with admin / admin.
- Go to Explore, choose Loki as the datasource.
- Run a query like:
```
{job="varlogs"}
You should start seeing logs from /var/log/*.log files on all nodes.
```

## 6. Alerting
Here alerts are generated and emailed when a monitored service is down.

## Setup Summary
- Service Monitored: /health endpoint
- Alert Tool: Prometheus
- Alert Delivery: Alertmanager
- Notification: Email to ezechinedum504@gmail.com
- Trigger: Service down for >30s (up == 0)

### Alert Rule
```bash
- alert: ServiceDown
  expr: up{job="health-endpoint"} == 0
  for: 30s
  ```
**NOTE**: This alert triggers if the health-endpoint service is down (up == 0) for more than 30 seconds continuously.
### Testing Steps
- Stop the /health endpoint
- Visit http://<minikube-ip>:30090/alerts
- Check email inbox/spam

### Troubleshooting
No email > Check App Password and Alertmanager logs
Alert not firing > Verify up metric in Prometheus Targets