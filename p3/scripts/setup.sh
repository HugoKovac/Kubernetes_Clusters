#!/bin/bash

# Création du cluster Kubernetes avec k3d
k3d cluster create dev-cluster --api-port 8000 --port 8888:30000@loadbalancer

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'ArgoCD dans le namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 10

echo wait for argo
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s

# External access point to ArgoCD
echo port-foward argo
kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &

# Initial password and future password
ARGOCD_PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
PASS="password"

# ArgoCD login
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Update password
argocd account update-password --current-password $ARGOCD_PASSWORD --new-password $PASS

# Login with new password
argocd logout localhost:8080
argocd login localhost:8080 --username admin --password $PASS --insecure

# ArgoCD app creation
argocd app create -f confs/wil-application.yaml
