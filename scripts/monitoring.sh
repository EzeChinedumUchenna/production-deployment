#!/bin/bash
set -e

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
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.service.type=NodePort \
  --set grafana.service.type=NodePort \
  --set alertmanager.service.type=NodePort

# Expose Grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np --namespace monitoring

kubectl expose service prometheus-kube-state-metrics --type=NodePort \
  --target-port=8080 --name=prometheus-kube-state-metrics-np --namespace monitoring

kubectl get svc -n monitoring

minikube addons enable ingress

echo "Installing Loki Stack (Loki + Promtail)..."
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set promtail.enabled=true 

# helm install loki grafana/loki-stack \
#   --namespace monitoring \
#   --set grafana.enabled=false \
#   --set prometheus.enabled=false \
#   --set loki.persistence.enabled=true \
#   --set promtail.enabled=true \


echo "Installing Grafana..."
helm install grafana grafana/grafana --namespace monitoring


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
