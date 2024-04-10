#!/bin/bash

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

sleep 45

# Exécutez kubectl get pods et extrayez le nom du pod
pod_name=$(kubectl get pods -o=name | grep wil-pod)

# Vérifiez si le nom du pod est trouvé
if [ -n "$pod_name" ]; then
	# Lancez le port-forwarding avec le nom du pod trouvé
	kubectl port-forward svc/wil-service 8888:8888 -n dev >/dev/null 2>&1 &
	echo "Port-forwarding démarré vers le pod $pod_name"
else
	echo "Aucun pod trouvé avec le nom wil-pod"
fi
