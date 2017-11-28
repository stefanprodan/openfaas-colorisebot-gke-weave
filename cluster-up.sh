#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

k8s_version=$(gcloud container get-server-config --format=json | jq -r '.validNodeVersions[0]')
echo "Using Kubernetes ${k8s_version}"

gcloud beta container clusters create demo \
    --cluster-version=${k8s_version} \
    --zone=europe-west1-d \
    --num-nodes=5 \
    --machine-type=n1-standard-4 \
    --min-cpu-platform="Intel Skylake" \
    --scopes=default,storage-rw

gcloud container clusters get-credentials demo

kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
    --clusterrole=cluster-admin \
    --user="$(gcloud config get-value core/account)"
