#!/bin/bash

# Création du cluster Kubernetes avec k3d
k3d cluster create mon-cluster --api-port 8000

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'ArgoCD dans le namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
