#!/bin/bash

# Création du cluster Kubernetes avec k3d
# Port forward les nodePort, du service de notre appli et du service argocd qu'on va patch en nodePort
echo k3d cluster creation...
k3d cluster create dev-cluster --api-port 8000 --port 8888:30000@loadbalancer --port 8080:30500@loadbalancer

# Création des namespaces
echo Namespace creation...
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

# Install gitlab instance with helm
echo gitlab creation...
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Using the gitlab helm chart
# Following the helm config subchart, minikube has a min config so we'll use this for boilerplate and disabling the gitlab-runner and cert-manager
# 0.0.0.0 Because we want every interface (and the ingress) to be able to talk with our gitlab webservice (i had issue for connecting to it otherwise)
# The domain is under gitlab., and we need to configure it in /etc/hosts on our node (which is our machine for this projects)
helm upgrade --install gitlab gitlab/gitlab \
	--namespace gitlab \
	-f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
	--set global.hosts.domain=gitlab.custom-domain.com \
	--set global.hosts.externalIP=0.0.0.0 \
	--set global.hosts.https=false \
	--timeout 600s

# Wait until all the gitlab pods are up (webservice is the last one to load, and the only one we need)
echo Waiting for the webservice pod...
sleep 10
kubectl wait --for=condition=Ready pod -l app=webservice -n gitlab --timeout=600s

# Get initial root password for gitlab
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)
echo $GITLAB_PASSWORD

# Forward the web-service, cant be bother to patch it to a nodePort or doing smth else, and cant manage to access it via ingress, would probably need a custom ingress on top due to k3d
echo Forwarding the web-service on port 8081...
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8081:8181 >/dev/null 2>&1 &

# Create aleduc gitlab folder with wilproj content before creating the gitops cd with argo
# Then launch app.sh
