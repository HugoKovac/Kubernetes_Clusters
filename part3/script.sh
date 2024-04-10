#!/bin/bash

# argocd password
PASS="password"

# Création du cluster Kubernetes avec k3d
k3d cluster create mon-cluster --api-port 8000

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Installation d'ArgoCD dans le namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Pause pour laisser le temps à ArgoCD de démarrer complètement (environ 30 secondes)
sleep 40

# Port-forwarding vers ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Récupération du mot de passe initial
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Connexion à ArgoCD
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Update password
argocd account update-password --current-password "$ARGOCD_PASSWORD" --new-password "$PASS"

# Logout of context
argocd logout localhost:8080

# Login with new password
argocd login localhost:8080 --username admin --password $PASS --insecure

# Création de l'application à partir du fichier YAML
argocd app create --file wil-app.yaml

# Liste des applications actuellement déployées
argocd app list

# Fix le status OutOfSync par defaut
argocd app sync wil-app

# Liste les pods dans le namespace de dev
kubectl get pods -n dev

# Arrêt du port-forwarding
kill %1
