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
