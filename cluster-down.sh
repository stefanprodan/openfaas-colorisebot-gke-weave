#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

k8s_zone=europe-west2-a

gcloud container clusters delete demo --zone=${k8s_zone}
gcloud compute disks delete minio-disk --zone=${k8s_zone}
