#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

kubectl delete -f ./namespaces.yaml
