#!/bin/bash

# External access point to ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Initial password and future password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
PASS="password"

# ArgoCD login
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Update password
argocd account update-password --current-password $ARGOCD_PASSWORD --new-password $PASS

# Login with new password
argocd logout localhost:8080
argocd login localhost:8080 --username admin --password $PASS --insecure

# ArgoCD app creation
argocd app create wilapp \
	--repo https://github.com/HugoKovac/Kubernetes_Clusters \
	--path part3 \
	--dest-server https://kubernetes.default.svc \
	--dest-namespace default \
	--sync-policy automated

# External access point to our pod (curl localhost:8888 after to check)
kubectl port-forward wil-pod-7dc8bc657c-zfsdz 8888:8888
