#!/bin/bash

# Création du cluster Kubernetes avec k3d
k3d cluster create dev-cluster --api-port 8000 --port 8080:80@loadbalancer --port 8443:443@loadbalancer --port 8888:8888@loadbalancer

# kubectl apply -f ingress.yml
# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Download argocd manifest
#wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Patch install manifest to add config to argocd
#sed -i '/- argocd-server/{n;/- --staticassets/{n;/- \/shared\/app/{s/$/\n        - --insecure\n        - --rootpath\n        - \/argocd/;};};}' install.yaml

# Installation d'ArgoCD dans le namespace argocd
#kubectl apply -n argocd -f install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 10

echo wait for argo
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s

echo port-foward argo
kubectl port-forward svc/argocd-server -n argocd 8080:80 >/dev/null 2>&1 &

# External access point to ArgoCD
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
argocd app create -f scripts/wil-application.yaml

sleep 10

echo wait for wilpod
kubectl wait --for=condition=Ready pod --all -n dev --timeout=300s

while true; do kubectl port-forward svc/wil-service 8888:8888 -n dev >/dev/null 2>&1 ; done&
