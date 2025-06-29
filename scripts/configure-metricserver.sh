#!/bin/bash
set -e

echo "📦 Installing metrics server via kubectl manifest..."
/usr/local/bin/kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --validate=false

echo "🚀 Enabling Minikube metrics-server addon (optional)..."
minikube addons enable metrics-server

echo "🔍 Checking metrics-server deployment status.."
kubectl get deployment metrics-server -n kube-system