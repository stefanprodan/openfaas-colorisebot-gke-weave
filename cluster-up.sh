#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

k8s_zone=europe-west2-a
k8s_zone_extra=europe-west2-b
k8s_version=$(gcloud container get-server-config --format=json | jq -r '.validNodeVersions[0]')
echo "Using Kubernetes ${k8s_version}"

gcloud container clusters create demo \
    --cluster-version=${k8s_version} \
    --zone=${k8s_zone} \
    --additional-zones=${k8s_zone_extra} \
    --num-nodes=2 \
    --machine-type=n1-standard-4 \
    --scopes=default,storage-rw

    #    --min-cpu-platform="Intel Skylake" \

gcloud compute disks create --size 10GB minio-disk --type=pd-ssd --zone=${k8s_zone}

gcloud container clusters get-credentials demo --zone=${k8s_zone}

kubectl create clusterrolebinding "cluster-admin-$(whoami)" \
    --clusterrole=cluster-admin \
    --user="$(gcloud config get-value core/account)"
