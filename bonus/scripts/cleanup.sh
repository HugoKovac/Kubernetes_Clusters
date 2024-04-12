#!/bin/bash

# Delete cluster
k3d cluster delete dev-cluster

# Delete helm repo
helm repo remove gitlab
