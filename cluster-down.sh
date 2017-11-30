#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

gcloud container clusters delete demo -z=europe-west1-d
gcloud compute disks delete minio-disk -z=europe-west1-d
