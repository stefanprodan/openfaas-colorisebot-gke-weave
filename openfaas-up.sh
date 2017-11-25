#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

get_gateway_ip() {
    kubectl -n openfaas describe service gateway-lb | grep Ingress | awk '{ print $NF }'
}

get_minio_ip() {
    kubectl -n openfaas-fn describe service minio-lb | grep Ingress | awk '{ print $NF }'
}

if [ -z "$minio_access_key" ]; then
 echo "minio_access_key is required"
 exit 1
fi

if [ -z "$twitter_consumer_key" ]; then
 echo "twitter_consumer_key is required"
 exit 1
fi

if [ -z "$twitter_account" ]; then
 echo "twitter_account is required"
 exit 1
fi

# create namespaces

twitter_account=${twitter_account} kubectl apply -f ./namespaces.yaml

# create Minio and Twitter secrets

kubectl -n openfaas create secret generic minio-auth \
    --from-literal=key=${minio_access_key} \
    --from-literal=secret=${minio_secret_key}

kubectl -n openfaas-fn create secret generic minio-auth \
    --from-literal=key=${minio_access_key} \
    --from-literal=secret=${minio_secret_key}

kubectl -n openfaas create secret generic twitter-auth \
    --from-literal=consumer_key=${twitter_consumer_key} \
    --from-literal=consumer_secret=${twitter_consumer_secret} \
    --from-literal=access_token=${twitter_access_token} \
    --from-literal=access_token_secret=${twitter_access_token_secret}

# deploy OpenFaaS core services

kubectl apply -f ./openfaas

# deploy Minio and Mailbox services

kubectl apply -f ./openfaas-fn

# print Gateway and Minio public IPs

until [[ "$(get_gateway_ip)" ]]
 do sleep 1;
 echo -n ".";
done

until [[ "$(get_minio_ip)" ]]
 do sleep 1;
 echo -n ".";
done

echo "."

gateway_ip=$(get_gateway_ip)
mino_ip=$(get_minio_ip)

echo "Gateway IP: ${gateway_ip}"
echo "Minio External IP: ${mino_ip}"

# create Minio colorization bucket

mc config host add gcp http://${mino_ip}:9000 ${minio_access_key} ${minio_secret_key}
mc mb gcp/colorization

# deploy colorisebot functions

faas-cli deploy -f ./stack.yaml --gateway=http://${gateway_ip}:8080
