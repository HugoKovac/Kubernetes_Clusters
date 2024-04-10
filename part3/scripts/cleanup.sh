#!/bin/bash

# Delete argo port forwarding
kill %1
kill %1

# Delete cluster
k3d cluster delete mon-cluster
