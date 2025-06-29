#!/bin/bash
set -e

# Ensure Minikube is running
if ! minikube status | grep -q "Running"; then
  echo "❌ Minikube is not running. Please start it before executing this script."
  exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
  echo "⚙️ Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "Creating 'monitoring' namespace..."
kubectl create namespace monitoring || echo "Namespace already exists"

echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Installing Prometheus (with Alertmanager)..."
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --set alertmanager.enabled=true \
  --set alertmanager.persistentVolume.enabled=false \
  --set server.persistentVolume.enabled=false

echo "Installing Loki Stack (Loki + Promtail)..."
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set promtail.enabled=true \
  --set grafana.enabled=false

echo "Installing Grafana..."
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set adminPassword='admin' \
  --set service.type=NodePort \
  --set persistence.enabled=false

echo "Waiting for Grafana to be ready..."
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=120s

echo "Checking Alertmanager pod status..."
kubectl get pods -n monitoring -l app=alertmanager

echo "You can expose Alertmanager if needed:"
echo "  kubectl port-forward svc/prometheus-alertmanager 9093 -n monitoring"
echo "  OR open NodePort via: minikube service prometheus-alertmanager -n monitoring"

echo "Grafana admin password:"
kubectl get secret --namespace monitoring grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

echo "Access Grafana in your browser:"
minikube service grafana -n monitoring
