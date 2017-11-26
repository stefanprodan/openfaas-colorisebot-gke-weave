# openfaas-colorisebot-gke-weave

OpenFaaS colorisebot GKE deployment instrumented with Weave Cloud

### Setup

Prerequisites: 

* gcloud
* kubectl 
* mc
* faas-cli
* jq, awk, base64

Run `gcloud init` and set the the default zone to `europe-west3-a`.

Create a GKE 3 nodes cluster:

```bash
./cluster-up.sh
```

Deploy OpenFaaS services, Caddy, Nats, Minio, Colorisebot services and functions, Weave Cloud agents:

```bash
basic_auth_user=<VAL> \
basic_auth_password=<VAL> \
twitter_account=<VAL> \
twitter_consumer_key=<VAL> \
twitter_consumer_secret=<VAL> \
twitter_access_token=<VAL> \
twitter_access_token_secret=<VAL> \
minio_access_key=<VAL> \
minio_secret_key=<VAL> \
weave_token=<VAL> \
./openfaas-up.sh
```

### Components

Namespace openfaas:

```bash
$ kubectl -n openfaas get deployments
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
alertmanager    1         1         1            1           16m
caddy           1         1         1            1           16m
faas-netesd     1         1         1            1           16m
gateway         1         1         1            1           16m
nats            1         1         1            1           16m
prometheus      1         1         1            1           16m
tweetlistener   1         1         1            1           15m
```

Namespace openfaas-fn:

```bash
$ kubectl -n openfaas-fn get deployments
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
colorization     1         1         1            1           14m
mailbox          1         1         1            1           16m
minio            1         1         1            1           16m
normalisecolor   1         1         1            1           15m
queue-worker     1         1         1            1           16m
tweetpic         1         1         1            1           14m
```

Namespace kube-system:

```bash
$ kubectl -n kube-system get deployments | grep weave
NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
weave-cortex-agent           1         1         1            1           25m
weave-cortex-state-metrics   1         1         1            1           25m
weave-flux-agent             1         1         1            1           25m
weave-flux-memcached         1         1         1            1           25m
```
