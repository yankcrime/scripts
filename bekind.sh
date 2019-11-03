#!/usr/bin/env bash
set -e

IMAGE="kindest/node:v1.16.2"
CLNAME="$2"
[ -z $CLNAME ] && CLNAME="kind"
kind create cluster --config $1 --name $CLNAME --image $IMAGE
export KUBECONFIG="$(kind get kubeconfig-path --name=$CLNAME)"
kubectl delete storageclass standard
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl annotate storageclass --overwrite local-path storageclass.kubernetes.io/is-default-class=true
