#!/bin/bash

# Création du cluster Kubernetes avec k3d
# Port forward les nodePort, du service de notre appli et du service argocd qu'on va patch en nodePort
echo k3d cluster creation...\n
k3d cluster create dev-cluster --api-port 8000 --port 8888:30000@loadbalancer --port 8080:30500@loadbalancer

# Création des namespaces
echo Namespace creation...\n
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

# Install gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@localhost \
  --set postgresql.image.tag=13.6.0


# Installation d'ArgoCD dans le namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# # Patch argocd service to be a nodePort, to use without portForwarding from the outside
# kubectl patch svc argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30500}]'

# # Wait until all the pods
# echo wait for the completion of argocd pods...\n
# sleep 10
# kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s

# # Initial password and future password
# ARGOCD_PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
# PASS="password"

# # ArgoCD login, update password, and login with new password
# echo ArgoCD login, update password, and login with new password...\n
# argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
# argocd account update-password --current-password $ARGOCD_PASSWORD --new-password $PASS
# argocd logout localhost:8080
# argocd login localhost:8080 --username admin --password $PASS --insecure

# # ArgoCD app creation
# echo App creation...\n
# argocd app create -f confs/wil-application.yaml
