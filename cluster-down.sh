#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

gcloud container clusters delete demo -z=europe-west1-d

