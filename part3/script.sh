#!/bin/bash

# Création du cluster Kubernetes avec k3d
k3d cluster create mon-cluster

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'ArgoCD dans le namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port-forwarding vers ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Récupération du mot de passe argocd
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Connexion à ArgoCD
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Liste des applications actuellement déployées
# Création de l'application à partir du fichier YAML
argocd app list
argocd app create --file my-app.yaml
argocd app list

# Arrêt du port-forwarding
kill %1
