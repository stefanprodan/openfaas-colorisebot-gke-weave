#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

get_gateway_ip() {
    kubectl -n openfaas describe service caddy-lb | grep Ingress | awk '{ print $NF }'
}

get_minio_ip() {
    kubectl -n openfaas-fn describe service minio-lb | grep Ingress | awk '{ print $NF }'
}

if [ -z "$basic_auth_user" ]; then
 echo "basic_auth_user is required"
 exit 1
fi

if [ -z "$minio_access_key" ]; then
 echo "minio_access_key is required"
 exit 1
fi

if [ -z "$twitter_account" ]; then
 echo "twitter_account is required"
 exit 1
fi

if [ -z "$twitter_consumer_key" ]; then
 echo "twitter_consumer_key is required"
 exit 1
fi

if [ -z "$weave_token" ]; then
 echo "weave_token is required"
 exit 1
fi

# install Weave Cloud agents
kubectl apply -n kube-system -f \
"https://cloud.weave.works/k8s.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')&t=${weave_token}"


# create namespaces
kubectl apply -f ./namespaces.yaml

# create Caddy, Minio and Twitter secrets
kubectl -n openfaas create secret generic basic-auth \
    --from-literal=user=${basic_auth_user} \
    --from-literal=password=${basic_auth_password}

kubectl -n openfaas create secret generic minio-auth \
    --from-literal=key=${minio_access_key} \
    --from-literal=secret=${minio_secret_key}

kubectl -n openfaas-fn create secret generic minio-auth \
    --from-literal=key=${minio_access_key} \
    --from-literal=secret=${minio_secret_key}

kubectl -n openfaas create secret generic twitter-auth \
    --from-literal=account=${twitter_account} \
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

echo "OpenFaaS Gateway IP: ${gateway_ip}"
echo "Minio External IP: ${mino_ip}"

# create Minio colorization bucket

mc config host add gcp http://${mino_ip}:9000 ${minio_access_key} ${minio_secret_key}
mc mb gcp/colorization

# create credentials file
if [ ! -f ./credentials.yaml ]; then
  echo -e "\nGenerating credentials.yaml"

  cat > ./credentials.yaml <<EOL
environment:
  minio_access_key: ${minio_access_key}
  minio_secret_key: ${minio_secret_key}
  consumer_key: ${twitter_consumer_key}
  consumer_secret: ${twitter_consumer_secret}
  access_token: ${twitter_access_token}
  access_token_secret: ${twitter_access_token_secret}
EOL
fi

# deploy colorisebot functions
echo ${basic_auth_password} | faas-cli login -u ${basic_auth_user} --password-stdin --gateway=http://${gateway_ip}
faas-cli deploy -f ./stack.yaml --gateway=http://${gateway_ip}

sleep 5

# scale to one pod per node
kubectl -n openfaas-fn scale --replicas=4 deployment/colorization
kubectl -n openfaas-fn scale --replicas=4 deployment/normalisecolor

# scale to one pod per CPU core
kubectl -n openfaas-fn scale --replicas=16 deployment/queue-worker
