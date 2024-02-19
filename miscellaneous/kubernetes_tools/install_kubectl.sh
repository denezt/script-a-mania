#!/bin/bash

kubedir="$HOME/.kube"
kubeversion='v1.23.6'
targetdir='/usr/bin/kubectl'

# Create my kube directory if not present
[ ! -d "$HOME/.kube" ] && mkdir -v $kubedir

pushd .
# Change working directory
cd ${kubedir}

# Download kubectl source binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/${kubeversion}/bin/linux/amd64/kubectl
cp -a -v $kubedir $targetdir
chmod 755 $targetdir
popd
