#!/bin/bash

# Delete port forwarding
kill %1
kill %1

# Delete cluster
k3d cluster delete dev-cluster
