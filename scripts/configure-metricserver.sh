#!/bin/bash
Install metric server - kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 
minikube addons enable metrics-server
kubectl get deployment metrics-server -n kube-system